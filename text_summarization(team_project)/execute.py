import pandas as pd
from generator_test_model import model_create
from word_to_index_and_padding import *
from test import *
from category_classification import category_classification

data = pd.read_excel('normalize_뇌물수수_add_nouns.xlsx')
data = data[data.notnull()]
data = data[data['TITLE'].notnull()]

for i in range(len(data)) :
    category = category_classification(data.CONTENT[i])
    content = pd.Series(data['CONTENT'][i]).to_list()
    title = pd.Series(data['TITLE'][i]).to_list()

    with open('word_dict/content_ix_to_word_' + category + '.pkl', 'rb') as f:
        content_ix_to_word = pickle.load(f)
    with open('word_dict/title_ix_to_word_' + category + '.pkl', 'rb') as f:
        title_ix_to_word = pickle.load(f)
    with open('word_dict/title_word_to_ix_' + category + '.pkl', 'rb') as f:
        title_word_to_ix = pickle.load(f)

    content_len_dict = {'날씨':[1421, 13], '사건_사고':[1190, 13], '뇌물수수':[1471, 17]}
    content_len, title_len = content_len_dict[category]

    pad_num = 0
    index_title, index_content = word_to_index(category, content, title)
    input_idx = seq_padding(index_content, content_len, pad_num, True)
    target_idx = seq_padding(index_title, title_len, pad_num, False)

    temp = pd.DataFrame(input_idx).to_numpy()
    temp = np.array([s[:content_len] for s in temp])
    input_data = temp
    temp = pd.DataFrame(target_idx).to_numpy()
    temp = np.array([s[:title_len] for s in temp])
    target_data = temp


    embedding_dim = 128

    if (category == '날씨') or (category == '뇌물수수') :
        hidden_size = 256
    else :
        hidden_size = 128

    model, output = model_create(category, embedding_dim, hidden_size)
    model.load_weights(category+'_'+str(embedding_dim)+'_'+str(hidden_size)+'/checkpoints')

    encoder_model, decoder_model = test(output, hidden_size, content_len)


    print("원문 : ", seq2text(input_data[0], content_ix_to_word))
    print("실제 요약문 :", seq2summary(target_data[0], title_word_to_ix, title_ix_to_word))
    print("예측 요약문 :", decode_sequence(input_data[0].reshape(1, content_len),
                                      encoder_model, decoder_model,
                                      title_word_to_ix, title_ix_to_word, title_len))
