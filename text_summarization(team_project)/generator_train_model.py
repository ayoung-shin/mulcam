import pandas as pd
import numpy as np
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Dense, Embedding, LSTM, Concatenate, Input
from tensorflow.keras.callbacks import EarlyStopping

from keras_tqdm import TQDMCallback

from sklearn.model_selection import train_test_split
import pickle

from word_to_index_and_padding import *

def generator_model(category, content, title, embedding_dim, hidden_size) :
    with open('word_dict/content_ix_to_word_'+category+'.pkl', 'rb') as f :
        content_ix_to_word = pickle.load(f)
    with open('word_dict/content_word_to_ix_'+category+'.pkl', 'rb') as f :
        content_word_to_ix = pickle.load(f)
    with open('word_dict/title_ix_to_word_'+category+'.pkl', 'rb') as f :
        title_ix_to_word = pickle.load(f)
    with open('word_dict/title_word_to_ix_'+category+'.pkl', 'rb') as f :
        title_word_to_ix = pickle.load(f)

    pad_num = 0
    oov_num = 1

    src_vocab = len(content_ix_to_word)
    tar_vocab = len(title_ix_to_word)
    # print(tar_vocab, src_vocab)
    index_title = change_word_to_index(title, title_word_to_ix, oov_num)
    index_content = change_word_to_index(content, content_word_to_ix, oov_num)

    content_len = max([len(x)-1 for x in index_content])
    title_len = max([len(x)-1 for x in index_title])
    # print(content_len, title_len)
    input_idx = seq_padding(index_content, content_len, pad_num, True)
    target_idx = seq_padding(index_title, title_len, pad_num, False)

    temp = pd.DataFrame(input_idx).to_numpy()
    temp = np.array([s[:-1] for s in temp])
    input_data = temp

    temp = pd.DataFrame(target_idx).to_numpy()
    temp = np.array([s[:-1] for s in temp])
    target_data = temp

    xTrain, xTest, yTrain, yTest = train_test_split(input_data, target_data, test_size=0.2, random_state=777, shuffle=True)

    ###### 모델 설계
    # 인코더
    encoder_inputs = Input(shape=(content_len,))

    # 인코더의 임베딩 층
    enc_emb = Embedding(src_vocab, embedding_dim)(encoder_inputs)

    # 인코더의 LSTM 1
    encoder_lstm1 = LSTM(hidden_size, return_sequences=True, return_state=True,
                         dropout=0.4, recurrent_dropout=0.4)
    encoder_output1, state_h1, state_c1 = encoder_lstm1(enc_emb)

    # 인코더의 LSTM 2
    encoder_lstm2 = LSTM(hidden_size, return_sequences=True, return_state=True,
                         dropout=0.4, recurrent_dropout=0.4)
    encoder_output2, state_h2, state_c2 = encoder_lstm2(encoder_output1)

    # 인코더의 LSTM 3
    encoder_lstm3 = LSTM(hidden_size, return_state=True, return_sequences=True,
                         dropout=0.4, recurrent_dropout=0.4)

    if category == '사건_사고':
        encoder_outputs, state_h, state_c = encoder_lstm3(encoder_output2)
    else:
        encoder_output3, state_h3, state_c3 = encoder_lstm3(encoder_output2)

        # 인코더의 LSTM 4
        encoder_lstm4 = LSTM(hidden_size, return_state=True, return_sequences=True,
                             dropout=0.4, recurrent_dropout=0.4)
        encoder_outputs, state_h, state_c = encoder_lstm4(encoder_output3)

    # 디코더
    decoder_inputs = Input(shape=(None,))

    # 디코더의 임베딩 층
    dec_emb_layer = Embedding(src_vocab, embedding_dim)
    dec_emb = dec_emb_layer(decoder_inputs)

    # 디코더의 LSTM
    decoder_lstm = LSTM(hidden_size, return_sequences=True,
                        return_state=True, dropout=0.4, recurrent_dropout=0.2)
    decoder_outputs, _, _ = decoder_lstm(dec_emb, initial_state=[state_h,
                                                                 state_c])

    # 디코더의 출력층
    decoder_softmax_layer = Dense(tar_vocab, activation='softmax')
    decoder_softmax_outputs = decoder_softmax_layer(decoder_outputs)

    # 모델 정의
    model = Model([encoder_inputs, decoder_inputs], decoder_softmax_outputs)

    import urllib.request
    urllib.request.urlretrieve("https://raw.githubusercontent.com/thushv89/attention_keras/master/layers/attention.py",
                               filename="attention.py")
    from attention import AttentionLayer

    # 어텐션 층(어텐션 함수)
    attn_layer = AttentionLayer(name='attention_layer')
    attn_out, attn_states = attn_layer([encoder_outputs, decoder_outputs])

    # 어텐션의 결과와 디코더의 hidden state들을 연결
    decoder_concat_input = Concatenate(axis=-1, name='concat_layer')(
        [decoder_outputs, attn_out])

    # 디코더의 출력층
    decoder_softmax_layer = Dense(tar_vocab, activation='softmax')
    decoder_softmax_outputs = decoder_softmax_layer(decoder_concat_input)

    # 모델 정의
    model = Model([encoder_inputs, decoder_inputs], decoder_softmax_outputs)

    if category == '날씨':
        model.compile(optimizer='rmsprop', loss='sparse_categorical_crossentropy')
    elif category == '사건_사고':
        model.compile(optimizer='adam', loss='sparse_categorical_crossentropy')
    else:
        from tensorflow.keras import optimizers

        adam = optimizers.Adam(lr=0.01, beta_1=0.8, beta_2=0.999, epsilon=None, decay=1e-5, amsgrad=False)
        model.compile(optimizer=adam, loss='sparse_categorical_crossentropy')

    es = EarlyStopping(monitor='val_loss', mode='min', verbose=1, patience=5)

    model.fit([xTrain, yTrain[:, :-1]], yTrain.reshape(yTrain.shape[0], yTrain.shape[1], 1)[:, 1:],
              epochs=50, callbacks=[es, TQDMCallback()], batch_size=32,
              validation_data=([xTest, yTest[:, :-1]], yTest.reshape(yTest.shape[0], yTest.shape[1], 1)[:, 1:]))

    model.save_weights(category+'_'+str(embedding_dim)+'_'+str(hidden_size)+'/checkpoints')

# 날씨
data = pd.read_excel('normalize_날씨_add_nouns.xlsx', index_col=0)
data = data[data.CONTENT.notnull()]
data = data[data.TITLE.notnull()]

embedding_dim = 128
hidden_size = 256

content = data['CONTENT'].to_list()
title = data['TITLE'].to_list()

generator_model('날씨', content, title, embedding_dim, hidden_size)

# 뇌물수수
data = pd.read_excel('normalize_뇌물수수_add_nouns.xlsx', index_col=0)
data = data[data.CONTENT.notnull()]
data = data[data.TITLE.notnull()]

embedding_dim = 128
hidden_size = 256

content = data['CONTENT'].to_list()
title = data['TITLE'].to_list()

generator_model('뇌물수수', content, title, embedding_dim, hidden_size)

# 사건_사고
data = pd.read_excel('normalize_사건_사고_add_nouns.xlsx', index_col=0)
data = data[data.CONTENT.notnull()]
data = data[data.TITLE.notnull()]

embedding_dim = 128
hidden_size = 128

content = data['CONTENT'].to_list()
title = data['TITLE'].to_list()

generator_model('사건_사고', content, title, embedding_dim, hidden_size)