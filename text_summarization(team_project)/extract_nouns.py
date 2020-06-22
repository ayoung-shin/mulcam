import pandas as pd

def extract_nouns(data) :    
    from konlpy.tag import Okt
    from tqdm import tqdm

    # 내용이 없는 데이터 행 삭제
    data = data[news.CONTENT.notnull()]
    data = data.reset_index(drop=True)
    
    # Okt 이용
    okt = Okt()
    news_nouns = []

    # 전체 데이터에 대하여 명사만 추출
    for text in tqdm(data.CONTENT):
        temp = ' '.join(okt.nouns(text))
        news_nouns.append(temp)

    # 명사 추출 결과를 데이터 'nouns'열로 저장
    data['nouns'] = news_nouns

    return data

# 날씨
# 데이터 불러오기
news = pd.read_excel('normalize_날씨.xlsx', index_col=0)
extract_nouns_result = extract_nouns(news)
extract_nouns_result.to_excel('normalize_날씨_add_nouns.xlsx')

# 뇌물수수
# 데이터 불러오기
news = pd.read_excel('normalize_뇌물수수.xlsx', index_col=0)
extract_nouns_result = extract_nouns(news)
extract_nouns_result.to_excel('normalize_뇌물수수_add_nouns.xlsx')

# 사건_사고
news = pd.read_excel('normalize_사건_사고.xlsx', index_col=0)
extract_nouns_result = extract_nouns(news)
extract_nouns_result.to_excel('normalize_사건_사고_add_nouns.xlsx')