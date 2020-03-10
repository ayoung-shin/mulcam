library(rvest)
library(tm)
library(stringr)

## 데이터를 가져올 날짜 데이터 생성
start_date = as.Date("2015-01-01")
end_date = as.Date("2020-02-29")
date_set = seq(as.Date(start_date), as.Date(end_date), by = "day")
date_set = format(date_set, format="%Y%m%d")

## sbs news 크롤링 & 저장
sbs_url = "https://news.sbs.co.kr/news/programMain.do?prog_cd=R1&broad_date=20200219"
sbs_html = read_html(sbs_url, encoding = "utf-8")
sbs_html

sbs_news = sbs_html %>%
  html_node("#container") %>% 
  html_node(".sn_section_w") %>%
  html_node(".snprg_list_w") %>%
  html_nodes(".spml_cont") %>% 
  html_nodes("span") %>% 
  html_text()
sbs_news

sbs_text = str_remove_all(sbs_news, "\\[.+\\]")
sbs_text = str_replace_all(sbs_text, 
                           "[[:punct:]]", " ")
sbs_text = str_replace_all(sbs_text, 
                           "[[:digit:]]", " ")
sbs_text

## 데이터 저장
write(paste(sbs_text, collapse = " "), "sbs/sbs_20200219.txt")

### 반복문
for (day in date_set){
  sbs_url = "https://news.sbs.co.kr/news/programMain.do?prog_cd=R1&broad_date="
  sbs_html = read_html(paste0(sbs_url, day), 
                       encoding = "utf-8")
  
  # 뉴스 크롤링
  sbs_news = sbs_html %>%
    html_node("#container") %>% 
    html_node(".sn_section_w") %>%
    html_node(".snprg_list_w") %>%
    html_nodes(".spml_cont") %>% 
    html_nodes("span") %>% 
    html_text()
  
  if (length(sbs_news) != 0){
    # 뉴스 전처리
    sbs_text = str_remove_all(sbs_news, "\\[.+\\]")
    sbs_text = str_replace_all(sbs_text, 
                               "[[:punct:]]", " ")
    sbs_text = str_replace_all(sbs_text, 
                               "[[:digit:]]", " ")
    
    # 파일로 저장
    write(paste(sbs_text, collapse = " "),
          paste0("news/sbs/sbs_", day, ".txt"))
  }
  
  # 공격으로 인지 방지
  Sys.sleep(30)
}

## ytn news 크롤링
ytn_url = "https://www.ytn.co.kr/news/news_night_list.php?mode=Day&day=20200219"
ytn_html = read_html(ytn_url, encoding = "utf-8")

ytn_news = ytn_html %>% 
  html_node(".wrap") %>% 
  html_node("#ytn_list_v2014") %>% 
  html_nodes(".news_list_v2014") %>% 
  html_node("dt") %>% 
  html_text()
ytn_news

ytn_text = str_remove_all(ytn_news, "\\[.+\\]")
ytn_text = str_replace_all(ytn_text, 
                           "[[:punct:]]", " ")
ytn_text = str_replace_all(ytn_text, 
                           "[[:digit:]]", " ")
ytn_text

### 반복문
for (day in date_set){
  ytn_url = "https://www.ytn.co.kr/news/news_night_list.php?mode=Day&day="
  ytn_html = read_html(paste0(ytn_url, day), 
                       encoding = "utf-8")
  
  # 뉴스 크롤링
  ytn_news = ytn_html %>%
    html_node(".wrap") %>% 
    html_node("#ytn_list_v2014") %>% 
    html_nodes(".news_list_v2014") %>% 
    html_node("dt") %>% 
    html_text()
  
  if (length(ytn_news) != 0){
    
    # 뉴스 전처리
    ytn_text = str_remove_all(ytn_news, "\\[.+\\]")
    ytn_text = str_replace_all(ytn_text, 
                               "[[:punct:]]", " ")
    ytn_text = str_replace_all(ytn_text, 
                               "[[:digit:]]", " ")
    ytn_text = str_replace_all(ytn_text,
                               "\\+|↑|~", " ")
    
    # 파일로 저장
    write(paste(ytn_text, collapse = " "),
          paste0("news/ytn/ytn_", day, ".txt"))
  }
  
  # 공격으로 인지 방지
  Sys.sleep(50)
}

## jtbc news 크롤링
jtbc_url = "http://news.jtbc.joins.com/Replay/news_replay.aspx?fcode=PR10000403&strSearchDate=20200218"

jtbc_html = read_html(jtbc_url, encoding = "utf-8")

jtbc_news = jtbc_html %>% 
  html_nodes(".bd") %>% 
  html_nodes(".title_cr") %>% 
  html_text()
jtbc_news


jtbc_text = str_remove_all(jtbc_news[-length(jtbc_news)], 
                           "\\[.+\\]")
jtbc_text = str_replace_all(jtbc_text,
                            "[[:punct:]]", " ")
jtbc_text = str_replace_all(jtbc_text, 
                            "[[:digit:]]", " ")
jtbc_text = str_replace_all(jtbc_text, "~", " ")

### 반복문
for (day in date_set){
  jtbc_url = "http://news.jtbc.joins.com/Replay/news_replay.aspx?fcode=PR10000403&strSearchDate="
  jtbc_html = read_html(paste0(jtbc_url, day), 
                        encoding = "utf-8")
  
  # 뉴스 크롤링
  jtbc_news = jtbc_html %>% 
    html_nodes(".bd") %>% 
    html_nodes(".title_cr") %>% 
    html_text()
  
  if (length(jtbc_news) != 0){
    # 뉴스 전처리
    jtbc_text = str_remove_all(jtbc_news[-length(jtbc_news)],
                               "\\[.+\\]")
    jtbc_text = str_replace_all(jtbc_text,
                                "[[:punct:]]", " ")
    jtbc_text = str_replace_all(jtbc_text, 
                                "[[:digit:]]", " ")
    jtbc_text = str_replace_all(jtbc_text, "~", " ")
    
    # 파일로 저장
    write(paste(jtbc_text, collapse = " "),
          paste0("news/jtbc/jtbc_", day, ".txt"))
  }
  
  # 공격으로 인지 방지
  Sys.sleep(50)
}


## 데이터 분석
### 데이터 불러오기
ytn_location = "C:/Users/student/Desktop/R_script/news/ytn"
ytn_list = list.files(ytn_location)

ytn_data = data.frame()

for (file in ytn_list){
  temp = read.csv(paste0(ytn_location, "/",file), header = FALSE, 
                  stringsAsFactors = FALSE, sep = "\\")
  ytn_data = rbind(ytn_data, temp)
}


### 데이터 전처리
ytn_corpus = str_replace_all(ytn_data, 
                             "[[:lower:]]", " ")
ytn_corpus = str_replace_all(ytn_corpus,
                             "[[:punct:]]", " ")
ytn_corpus = str_replace_all(
  ytn_corpus,
  "#|%|\\(|\\)|↑|↓|`|‘|’|“|”|\\＋|\\/|‥|○", " ")
ytn_corpus = str_replace_all(ytn_corpus,
                             "[[:space:]]+", " ")

### TFIDF 생성
ytn_tfidf = DocumentTermMatrix(
  VCorpus(VectorSource(ytn_corpus)),
  control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE)))


inspect(ytn_corpus[[1]])
ytn_tfidf[1,]$dimnames$Terms
