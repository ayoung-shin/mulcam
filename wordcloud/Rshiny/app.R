library(shiny)
library(ggplot2)

library(memoise)
library(tm)
library(stringr)
library(rJava)
library(SnowballC)
library(wordcloud)
# library(KoNLP)

source("news/code_for_shiny.R")

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # Application title
    titlePanel("Wordcloud of the year by Each Broadcaster"),
    
    # Sidebar with a slider and selection inputs
    sidebarLayout(
        sidebarPanel(
            radioButtons("broadcast", "Choose a broadcaster",
                        choices = list("SBS", "JTBC", "YTN")),
            selectInput("year", "Choose a year",
                        choices = c("2015", "2016", "2017", "2018", "2019", "2020")),
            actionButton("update", "Change"),
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("plot", width = "100%", height = "650px")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    # 분석 결과에 대한 입력값 정의
    terms = reactive({
        # "updata"를 눌렀을 때 변화
        input$update
        
        # 아무것도 하지 않았을 경우
        isolate({
            withProgress({
                setProgress(message = "Processing corpus...")
                getAnalResult(tolower(input$broadcast), input$year)
            })
        })
    })
    
    # Make the wordcloud drawing predictable during a session
    wordcloud_rep = repeatable(wordcloud)
    
    output$plot <- renderPlot({
        v = terms()
        wordcloud_rep(
            names(v), 
            v,
            # 빈도가 가장 큰 단어와 가장 작은 단어 폰트 사이의 크기
            scale = c(5, 0.2),
            # # 90도 회전해서 보여줄 단어 비율
            rot.per = 0,
            # # 빈도 2 이상
            min.freq = 2,
            # # T:random, F:빈도수가 큰단어를 중앙에 배치
            random.order = F,
            # # T:random, F:빈도순
            random.color = F,
            colors = brewer.pal(10, "Paired")
        )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
