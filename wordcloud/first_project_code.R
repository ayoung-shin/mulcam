setwd("C:/Users/young/Desktop/news")

# install.packages("tm")
# install.packages("stringr")
# install.packages("rJava")
# install.packages("SnowballC")
# install.packages("wordcloud")

# install.packages("Sejong")
# install.packages("hash")
# install.packages("tau")
# install.packages("RSQLite")
# install.packages("rgdal")
# install.packages("geojsonio")
# install.packages("rgeos")
# install.packages("httpuv")

library(tm)
library(stringr)
library(rJava)
library(SnowballC)
library(wordcloud)

# library(Sejong)
# library(hash)
# library(tau)
# library(RSQLite)
# library(rgdal)
# library(geojsonio)
# library(rgeos)
# library(httpuv)
library(KoNLP)


sbs_location = "C:/Users/student/Desktop/news/sbs"
sbs_list = list.files(sbs_location)

sbs_data = data.frame()
for(file in sbs_list){
  temp = read.csv(paste0(sbs_location,"/", file), header = FALSE, 
                  stringsAsFactors = FALSE, sep = "\\")
  sbs_data = rbind(sbs_data, temp)
}

sbs_data$year = substr(sbs_list, 5, 8)
sbs_2015 = sbs_data$V1[sbs_data$year == "2020"]
sbs_text = str_replace_all(sbs_2015, "[[:lower:]]", " ")
sbs_text = str_replace_all(sbs_text, "[[:upper:]]", " ")
sbs_text = str_replace_all(sbs_text, "[^[:alpha:][:digit:]]", " ") # 특수문자 제거
sbs_text = str_replace_all(sbs_text, "[\u4E00-\u9FD5o]", " ") # 한자 제거
sbs_text = str_replace_all(sbs_text, "[[:space:]]+", " ")


##########################3
# sbs_corpus = VCorpus(VectorSource(sbs_text))
# sbs_corpus = tm_map(sbs_corpus, stemDocument)
# 
# sbs_tfidf = DocumentTermMatrix(
#   sbs_corpus,
#   control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE)))
# 
# sbs_tfidf$dimnames$Terms
# sbs_text[]
###############################3
# table(unlist(lapply(paste(extractNoun(sbs_text), collapse = " "), function(x) str_extract_all(x, boundary("word")))))
tmp = lapply(sbs_text, function(x) extractNoun(x))
dtm.k2 = DocumentTermMatrix(
  VCorpus(VectorSource(tmp)),
  control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE)))

# class(dtm.k2)
# dtm.df = as.data.frame(as.matrix(dtm.k2))
# dtm.label.df = cbind(dtm.df, LABEL = sbs_list[1:365])
# head(dtm.label.df)

# colnames(dtm.k2)
# findFreqTerms(dtm.k2, highfreq = 5)
# findAssocs(dtm.k2, "한국인", 0.1)
dtm.k2.freq = findMostFreqTerms(dtm.k2)
names(dtm.k2.freq) = NULL
# head(dtm.k2.freq)
# table(names(unlist(dtm.k2.freq)))
# table(names(unlist(dtm.k2.freq)))[table(names(unlist(dtm.k2.freq))) == max(table(names(unlist(dtm.k2.freq))))]
dtm.k2.freq.table = table(names(unlist(dtm.k2.freq)))


windows()
wordcloud(
  names(dtm.k2.freq.table),
  freq = dtm.k2.freq.table,
  scale = c(5, 0.2), # 빈도가 가장 큰 단어와 가장 작은 단어 폰트 사이의 크기
  rot.per = 0, # 90도 회전해서 보여줄 단어 비율
  min.freq = 2, # 빈도 2 이상
  random.order = F, # T:random, F:빈도수가 큰단어를 중앙에 배치
  random.color = F, # T:random, F:빈도순
  colors = brewer.pal(11, "Paired") # 11은 사용할 색상 개수, 두번째는 색상타입이름
  )

##########
# ytn
ytn_location = "C:/Users/young/Desktop/news/ytn"
ytn_list = list.files(ytn_location)

ytn_data = data.frame()
for(file in ytn_list){
  temp = read.csv(paste0(ytn_location,"/", file), header = FALSE, 
                  stringsAsFactors = FALSE, sep = "\\")
  if(nrow(temp)>1) temp = data.frame(V1 = paste(temp$V1, collapse = " "))
  
  ytn_data = rbind(ytn_data, temp)
}

ytn_data$year = substr(ytn_list, 5, 8)
{
ytn_sub = ytn_data$V1[ytn_data$year == "2020"]
ytn_text = str_replace_all(ytn_sub, "[[:lower:]]", " ")
ytn_text = str_replace_all(ytn_text, "[[:upper:]]", " ")
ytn_text = str_replace_all(ytn_text, "[^[:alpha:][:digit:]]", " ") # 특수문자 제거
ytn_text = str_replace_all(ytn_text, "[\u4E00-\u9FD5o]", " ") # 한자 제거
ytn_text = str_replace_all(ytn_text, "[[:space:]]+", " ")

tmp = lapply(ytn_text, function(x) extractNoun(x))
dtm.k2 = DocumentTermMatrix(
  VCorpus(VectorSource(tmp)),
  control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE)))

dtm.k2.freq = findMostFreqTerms(dtm.k2)
names(dtm.k2.freq) = NULL
dtm.k2.freq.table = table(names(unlist(dtm.k2.freq)))

windows()
wordcloud(
  names(dtm.k2.freq.table),
  freq = dtm.k2.freq.table,
  scale = c(5, 0.2), # 빈도가 가장 큰 단어와 가장 작은 단어 폰트 사이의 크기
  rot.per = 0, # 90도 회전해서 보여줄 단어 비율
  min.freq = 2, # 빈도 2 이상
  random.order = F, # T:random, F:빈도수가 큰단어를 중앙에 배치
  random.color = F, # T:random, F:빈도순
  colors = brewer.pal(11, "Paired") # 11은 사용할 색상 개수, 두번째는 색상타입이름
)
}
########
# jtbc
jtbc_location = "C:/Users/young/Desktop/news/jtbc"
jtbc_list = list.files(jtbc_location)

jtbc_data = data.frame()
for(file in jtbc_list){
  temp = read.csv(paste0(jtbc_location,"/", file), header = FALSE, 
                  stringsAsFactors = FALSE, sep = "\\")
  if(nrow(temp)>1) temp = data.frame(V1 = paste(temp$V1, collapse = " "))
  
  jtbc_data = rbind(jtbc_data, temp)
}

jtbc_data$year = substr(jtbc_list, 6, 9)
{
  jtbc_sub = jtbc_data$V1[jtbc_data$year == "2020"]
  jtbc_text = str_replace_all(jtbc_sub, "[[:lower:]]", " ")
  jtbc_text = str_replace_all(jtbc_text, "[[:upper:]]", " ")
  jtbc_text = str_replace_all(jtbc_text, "[^[:alpha:][:digit:]]", " ") # 특수문자 제거
  jtbc_text = str_replace_all(jtbc_text, "[\u4E00-\u9FD5o]", " ") # 한자 제거
  jtbc_text = str_replace_all(jtbc_text, "[[:space:]]+", " ")
  
  tmp = lapply(jtbc_text, function(x) extractNoun(x))
  dtm.k2 = DocumentTermMatrix(
    VCorpus(VectorSource(tmp)),
    control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE)))
  
  dtm.k2.freq = findMostFreqTerms(dtm.k2)
  names(dtm.k2.freq) = NULL
  dtm.k2.freq.table = table(names(unlist(dtm.k2.freq)))
  
  windows()
  wordcloud(
    names(dtm.k2.freq.table),
    freq = dtm.k2.freq.table,
    scale = c(5, 0.2), # 빈도가 가장 큰 단어와 가장 작은 단어 폰트 사이의 크기
    rot.per = 0, # 90도 회전해서 보여줄 단어 비율
    min.freq = 2, # 빈도 2 이상
    random.order = F, # T:random, F:빈도수가 큰단어를 중앙에 배치
    random.color = F, # T:random, F:빈도순
    colors = brewer.pal(11, "Paired") # 11은 사용할 색상 개수, 두번째는 색상타입이름
  )
}
