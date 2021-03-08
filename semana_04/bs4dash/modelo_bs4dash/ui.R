library(shiny)
library(bs4Dash)


# Define a interface gráfica para aplicação Shiny
# Documentação para consulta: 
#   bs4Dash - https://rinterface.github.io/bs4Dash/articles/bs4Intro.html  

shinyUI(
    bs4DashPage(
        old_school = FALSE,
        sidebar_mini = TRUE,
        sidebar_collapsed = TRUE,
        controlbar_collapsed = TRUE,
        controlbar_overlay = FALSE,
        title = "Zetta Health Analytics",
        navbar = bs4DashNavbar(),
        sidebar = bs4DashSidebar(
            skin = "light",
            title = "Zetta Academy",
            elevation = 1,
            brandColor = "white",
            src = "zettahealth.png",
            bs4SidebarMenu(
                bs4SidebarHeader("COVID 19 - Estatísticas"),
                bs4SidebarMenuItem(
                    "Mapa",
                    tabName = "item1",
                    icon = "map"
                ),
                bs4SidebarMenuItem(
                    "Gráficos",
                    tabName = "item2",
                    icon = "bar-chart"
                ),
                bs4SidebarMenuItem(
                    "Tabelas",
                    tabName = "item3",
                    icon = "list"
                )
            )
        ),
        footer = bs4DashFooter(
            copyrights = "Zetta Health Analytics - Curso de Dashboards com Shiny",
            right_text = "2021"
        ),
        body = bs4DashBody(
            bs4TabItems(
                bs4TabItem(tabName = "item1",
                           fluidRow(
                               h1("Mapa")
                           )),
                bs4TabItem(tabName = "item2",
                           fluidRow(
                               h1("Gráficos")
                           )),
                bs4TabItem(tabName = "item3",
                           fluidRow(
                               h1("Tabela")
                           ))
            )
        )
    )
)
