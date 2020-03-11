getAnalResult = memoise(function(broadcast, year){
  
  cast_location = paste0("news/", broadcast)
  cast_list = list.files(cast_location)
  
  cast_data = data.frame()
  for(file in cast_list){
    temp = read.csv(paste0(cast_location,"/", file), header = FALSE, 
                    stringsAsFactors = FALSE, sep = "\\")
    if(nrow(temp)>1) temp = data.frame(V1 = paste(temp$V1, collapse = " "))
    
    cast_data = rbind(cast_data, temp)
  }
  
  if(broadcast == "jtbc")
    cast_data$year = substr(cast_list, 6, 9)
  else cast_data$year = substr(cast_list, 5, 8)
  
  cast_year = cast_data$V1[cast_data$year == year]
  cast_text = str_replace_all(cast_year, "[[:lower:]]", " ")
  cast_text = str_replace_all(cast_text, "[[:upper:]]", " ")
  cast_text = str_replace_all(cast_text, "[^[:alpha:][:digit:]]", " ") # 특수문자 제거
  cast_text = str_replace_all(cast_text, "[\u4E00-\u9FD5o]", " ") # 한자 제거
  cast_text = str_replace_all(cast_text, "[[:space:]]+", " ")
  
  # KoNLP 사용
  # tmp = lapply(cast_text, function(x) extractNoun(x))
  # dtm.k2 = DocumentTermMatrix(
  #   VCorpus(VectorSource(tmp)),
  #   control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE))
  #   )
  
  # KoNLP 제외
  cast_corpus = VCorpus(VectorSource(cast_text))
  cast_corpus = tm_map(cast_corpus, stemDocument)

  dtm.k2 = DocumentTermMatrix(
    cast_corpus,
    control = list(weighting = function(x) weightTfIdf(x, normalize = FALSE))
    )

  
  dtm.k2.freq = findMostFreqTerms(dtm.k2)
  names(dtm.k2.freq) = NULL
  dtm.k2.freq.table = table(names(unlist(dtm.k2.freq)))
  
  dtm.k2.freq.table
})

