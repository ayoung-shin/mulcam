import pandas as pd

def get_TFIDF_top20(data) :
    import numpy as np
    from sklearn.feature_extraction.text import TfidfVectorizer

    # TFIDF 구성
    vectorizer = TfidfVectorizer()
    tfidf = vectorizer.fit_transform(data.nouns)

    # 각 행의 점수가 높은 단어 top20개 추출 하여 .xlsx로 저장
    index_to_word = {idx: word for idx, word in enumerate(vectorizer.get_feature_names())}
    tfidf = tfidf.todense()
    doc_word_index = [np.argsort(np.array(doc)[0])[-20:] for doc in tfidf]
    doc_word = [[index_to_word[idx] for idx in doc] for doc in doc_word_index]
    
    return pd.DataFrame(doc_word)

# 날씨
news = pd.read_excel('normalize_날씨_add_nouns.xlsx', index_col=0)
doc_word = get_TFIDF_top20(news)
doc_word.to_excel('TFIDF/날씨.xlsx')

# 뇌물수수
news = pd.read_excel('normalize_뇌물수수_add_nouns.xlsx', index_col=0)
doc_word = get_TFIDF_top20(news)
doc_word.to_excel('TFIDF/뇌물수수.xlsx')

# 사건_사고
news = pd.read_excel('normalize_사건_사고_add_nouns.xlsx', index_col=0)
doc_word = get_TFIDF_top20(news)
doc_word.to_excel('TFIDF/사건_사고.xlsx')