import pandas as pd
from normalize import normalize

# 본문에 있는 영어, 숫자, 특수문자 제거 후 저장
# 날씨
data = pd.read_excel('날씨.xlsx', index_col=0)
data['TITLE'] = data['TITLE'].apply(lambda x: x.replace(x, normalize(x)))
data['CONTENT'] = data['CONTENT'].apply(lambda x: x.replace(x, normalize(x)))
data.to_excel('normalize_날씨.xlsx')

# 뇌물수수
data = pd.read_excel('뇌물수수.xlsx', index_col=0)
data['TITLE'] = data['TITLE'].apply(lambda x: x.replace(x, normalize(x)))
data['CONTENT'] = data['CONTENT'].apply(lambda x: x.replace(x, normalize(x)))
data.to_excel('normalize_뇌물수수.xlsx')

# 사건_사고
data = pd.read_excel('사건_사고.xlsx', index_col=0)
data['TITLE'] = data['TITLE'].apply(lambda x: x.replace(x, normalize(x)))
data['CONTENT'] = data['CONTENT'].apply(lambda x: x.replace(x, normalize(x)))
data.to_excel('normalize_사건_사고.xlsx')