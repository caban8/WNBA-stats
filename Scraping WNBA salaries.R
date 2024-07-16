library(rvest)
library(tidyverse)

# Ustalam wektor referencyjny do pętli pobierania url
url <- str_c("https://www.spotrac.com/wnba/rankings/",2018:2023, "/cap-hit/")



# Tworzę listędo loopki
wnba_list <- list()

# Loopka do pobierania danych dla każdego roku
for (i in seq_along(url)) {
  
  # Pobieram dane z konkretnego roku
  x <- url[[i]] %>% 
    read_html() %>% 
    html_nodes(".ranklist") %>% 
    html_table(fill = TRUE)
  
  # Wybieram docelowe zmienne oraz dodaje zmienną rok
  wnba_list[[i]] <- x[[1]]  %>% 
    select(Player, `cap hit`)  %>% 
    mutate(
      Year = 2017 + i,
      Year_id = str_c(Year, "_", row_number())  # Do identyfikacji dziwnnych obserwacji
      )
}

wnba_list[[1]]$Player

# Sprawdzam przykładowy pattern stringowy
wnba_list[[1]] %>% 
  slice(1) %>% 
  pull(1)


# Łączę bazy do jednej 
wnba_list2 <- wnba_list %>% 
  reduce(add_row) 


# wyciągam imię i nazwisko graczki
wnba_list3 <- wnba_list2 %>% 
  mutate(
    Team = str_extract(Player, "[A-Z]{2,3}$"),
    Player = str_extract(Player, "\\t[a-zA-Z]* [a-zA-Z]*") %>% str_replace("\\t", "")
  ) 


# Sprawdzam, które obserwacje 
wnba_list3 %>% 
  mutate(length = str_length(Player)) %>% 
  arrange(length) %>% 
  print(n = 20)

filt_strange <- wnba_list3 %>% 
  mutate(length = str_length(Player)) %>% 
  arrange(length) %>% 
  slice(1:10) %>% 
  pull(Year_id)

# Sprawdzam 
wnba_list2 %>% 
  filter(Year_id %in% filt_strange) %>% 
  pull(Player)

# Chodzi o szczególne znaki: ', á, oraz ü


# Naprawiam
wnba_list3_b <- wnba_list2 %>% 
  mutate(
    Team = str_extract(Player, "[A-Z]{2,3}$"),
    Player = str_extract(Player, "\\t[a-zA-Z'áü]* [a-zA-Z'áü]*") %>% str_replace("\\t", "")
  ) 
  
# Sprawdzam ponownie
wnba_list3_b %>% 
  mutate(length = str_length(Player)) %>% 
  arrange(length) %>% 
  print(n = 20) # wszystko ok


# Sprawdzam jeszcze kodowanie dla Teamu
wnba_list3_b %>% 
  mutate(length = str_length(Team)) %>% 
  arrange(length) %>% 
  print(n = 20) # wszystko ok

wnba_list3_b %>% 
  mutate(length = str_length(Team)) %>% 
  arrange(desc(length)) %>% 
  print(n = 20) # wszystko ok


# Eksport
wnba_list3_b %>% 
  select(
    Player, Salary = `cap hit`, Year
  ) %>% 
  write_csv("WNBA - salaries.csv")
