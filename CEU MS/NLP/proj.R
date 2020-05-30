setwd("C:/Users/faaez/OneDrive - Central European University/Current Courses/NLP")

library(tidyverse)
library(stringr)
library(tidytext)
library(textstem)
library(spacyr)
library(textdata)
library(h2o)
library(skimr)

df <- read_csv("mbti_1.csv")

make_features <- function(df) {

  cleantext <- function(text){
    text <- gsub("/r/[0-9A-Za-z]", "", text)
    text <- gsub('(http[^ ]*)|(www\\.[^ ]*)', "", text)
    text <- gsub("[]|||[]", " ", text)
    text <- lemmatize_strings(text)
    return(text)
  }
  
  check_type <- function(word){
    if(word %in% MBTI_types){
      return(TRUE)
    } else {
      return(FALSE)
    }
  }
  
  cleanword <- function(word) {
    word <- str_to_lower(word)
    word <- str_replace(word, " [^A-Za-z]", "")
    word <- str_replace(word, '\\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}\\b',  "")
    return(word)
  }
  
  cleantypes <- function(word){
    if(word %in% MBTI_types){
      return(NA)
    }
    return(word)
  }
  
  MBTI_types <- c('INFJ', 'ENTP', 'INTP', 'INTJ', 'ENTJ', 'ENFJ', 'INFP', 'ENFP', 'ISFP', 'ISTP', 'ISFJ', 'ISTJ', 'ESTP', 'ESFP', 'ESTJ', 'ESFJ','MBTI')
  MBTI_types <- MBTI_types %>% map(str_to_lower)
  
  df$posts <- df$posts %>% map(cleantext)
  df <- df %>% mutate(id = rownames(df))
  df1 <- df %>% unnest_tokens(word, posts, token = "tweets", to_lower = FALSE)
  x <- "public speaking class a few years ago and Ive sort of learned what I could do better were I to be in that position again. A big part of my failure was just overloading myself with too...   I like this persons mentality. He's a confirmed INTJ"
  df2 <- df1
  df2$word <- df2$word %>% map_chr(cleanword)
  df2$word <- df2$word %>% map_chr(cleantypes)
  df2 <- na.omit(df2)
  df2
  #regex for url = (?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+
  
  #write_csv(df2, "words_list.csv")
  data("stop_words")
  stop_words
  df2 <- df2 %>% anti_join(stop_words, by = "word")
  
  df2 <- df2 %>% left_join(parts_of_speech, by = "word")
  df2 <- df2 %>% mutate(pos = ifelse(is.na(pos), "Noun", pos))
  df2 <- distinct(df2 %>% mutate(pos = ifelse(str_detect(pos, "Noun"), "Noun", 
                              ifelse(str_detect(pos, "Adverb"), "Adver", 
                                     ifelse(str_detect(pos, "Verb"), "Verb", 
                                            ifelse(str_detect(pos, "Article"), "Article", pos))))))
  df_count <- distinct(df2 %>% group_by(id, pos) %>% transmute(type, count = n()))
  df_count_total <- distinct(df2 %>% group_by(id) %>% transmute(total_count = n()))
  unique(df2$pos)
  df_for <- spread(df_count, pos, count, fill = 0)
  df_for <- merge(df_count_total, df_for) %>% rowwise() %>% mutate(for_score =  0.5*sum(Noun,Adjective,Preposition,Article)/total_count - 0.5*sum(Pronoun,Verb,Adver,Interjection)/total_count)
  df_idf1 <- df2 %>% count(id, word, sort = TRUE)
  df_idf2 <- df_idf1 %>% group_by(id) %>% summarise(total = sum(n))
  df_idf <- df_idf1 %>%
    bind_tf_idf(word, id, n) 
  df_idf <- left_join(df_idf, df2 %>% transmute(id, type) %>% distinct())
  
  library(forcats)
  
  plot_physics <- df_idf %>%
    mutate(word = fct_reorder(word, tf_idf)) %>%
    mutate(type = as.factor(type))
  
  plot_physics %>% 
    group_by(type) %>% 
    top_n(5, tf_idf) %>% 
    ungroup() %>%
    mutate(word = reorder(word, tf_idf)) %>%
    ggplot(aes(word, tf_idf, fill = type)) +
    geom_col(show.legend = FALSE) +
    labs(x = NULL, y = "tf-idf") +
    facet_wrap(~type, ncol = 2, scales = "free") +
    coord_flip()
  
  df_idf <- df_idf %>% group_by(id) %>% summarise(avg_tf_idf = mean(tf_idf))
  
  nrc <- get_sentiments("nrc")
  df_nrc <- left_join(df2, nrc)
  df_nrc1 <- na.omit(df_nrc) %>% group_by(id, sentiment) %>% transmute(count = n()) %>% distinct()
  df_nrc1 <- spread(df_nrc1, sentiment, count, fill = 0) 
  df_nrc1 <- left_join(df_nrc1, df_idf2)
  df_nrc1 <- df_nrc1 %>% transmute(anger = anger/total, 
                     anticipation = anticipation/total,
                     disgust = disgust/total,
                     fear = fear/total,
                     joy = joy/total,
                     sentiment = (positive - negative)/total,
                     sadness = sadness/total,
                     surprise = surprise/total,
                     trust = trust/total)
  
  df <- left_join(df_for, df_nrc1)
  
  df_wlen <- df1 %>% mutate(len_w = nchar(word)) %>% group_by(id) %>% transmute(avg_word_length = mean(len_w)) %>% distinct()
  
  df_vad <- left_join(df2, lexicon_nrc_vad(), by = c("word" = "Word")) %>% na.omit() %>% transmute(id, Valence, Arousal, Dominance)
  df_vad <- df_vad %>% group_by(id) %>% summarise(avg_valence = mean(Valence), avg_arousal = mean(Arousal), avg_dominance = mean(Dominance))
  df <- left_join(df, df_wlen)
  df <- left_join(df, df_vad)
  df <- left_join(df, df_idf)
  df <- df %>% select(id, type, for_score, anger, anticipation, disgust, fear, joy, sentiment, sadness, surprise, trust, avg_word_length, avg_valence, avg_arousal, avg_dominance, avg_tf_idf) %>% mutate(type = as.factor(type))
  
  return(df)
  
}

###########################
df_final <- df %>% select(!id)
h2o.init()
data <- as.h2o(df_final)
splitted_data <- h2o.splitFrame(data, 
                                ratios = c(0.7), 
                                seed = 123)
data_train <- splitted_data[[1]]
data_train$type <- as.factor(data_train$type)
data_valid <- splitted_data[[2]]


data_train <- as.h2o(data_train)

y <- "type"
x <- setdiff(names(data_train), y)

glm_model <- h2o.glm(
  x, y,
  training_frame = data_train,
  family = "multinomial",
  alpha = 0, 
  lambda_search = TRUE,
  seed = 123,
  nfolds = 5, 
  keep_cross_validation_predictions = TRUE  # this is necessary to perform later stacking
)

gbm_model <- h2o.gbm(
  x, y,
  training_frame = data_train,
  ntrees = 1500, 
  max_depth = 100, 
  learn_rate = 0.1, 
  seed = 123,
  nfolds = 5,
  distribution = "multinomial",
  stopping_metric = "RMSE", stopping_rounds = 3,
  stopping_tolerance = 1e-3,
  keep_cross_validation_predictions = TRUE
)


print(h2o.rmse(h2o.performance(glm_model, newdata = data_valid)))

print(h2o.rmse(h2o.performance(gbm_model, newdata = data_valid)))
df_test <- data.frame("type" = "entj", "posts" = "Social media today is the single most powerful source of information and disinformation around the world. With that the availability of an online pulpit, the availability of ideology, the availability of people supporting it, there is an increase in the propensity and proclivity of certain behaviours to foster. The world saw an increase in hate crimes, and communal violence in recent years - more so in countries where the populist leaders openly gratify extremist ideas. In terms of relevance to Pakistan, Safoora Goth and Sabeen Mahmud's assassination are linked to educated youth, entailing the process of self-radicalisation through social media.

Also, because of the availability of all kinds of propaganda, the digital environment is becoming conducive to augmented revolutions, riots and uprisings. For some, this is petrifying and for others, it is stimulating. The dramatic ousting of President Hosni Mubarak in Egypt and the lawyers' movement in Pakistan are a few successful examples of social media mobilisation.

It has become easier to manipulate information on the internet, especially for governments looking to do this through surreptitious means - use of chat bots, keyboard armies, fake accounts to name a few. In the past, there were only hand-held anchors on mass media - but today - we have hand-held gizmos, or the mix of both to distort and shape public opinion. The pro-democracy think tank 'Freedom House' reported that manipulation tactics in elections were found in 18 countries including the US in past one year.

Considering that the social media is being weaponised around the world, the governments are extensively looking to stifle opinions. This is particularly arduous as there is no agreed upon distinction on where to draw the line.

The opinion makers around the world are fighting over the civil liberties in terms of 'how much is too much' when it comes to allowing dissent and critique - from Charlie Hebdo in France, to blasphemy cases in Pakistan. Some argue that one's liberty to swing fist ends just where other's nose begins. Others argue that nobody can discuss polemics without offending anyone. And the moderates argue that one should learn the art to discuss controversial topics - it's not about what you say, it's about how you say it. So, by and large, there is no clarity in this debate.

Albeit, hate speech is something that translates into instigation against a person or group on the basis of attributes such as race, religion, ethnic origin, sexual orientation, disability, or gender. In several scenarios, it can translate into instigating people to kill someone without any obvious reason. In Pakistan, there are several laws like PPC-153-A - Promoting enmity between different groups, etc. - and in newly drafted cybercrimes law that goes by the title Prevention of Electronic Crimes Act 2016 (PECA) which criminalise hate speech. But fatwas calling people traitors and blasphemous are commonly hurled. Sometimes, it is used as a tool to stifle opinions and critiques against the state institutions on social media.

svg%3E
Whilst it is a dying notion that civil liberties are cemented across the world, it is 'heads I lose, tails you win' kind of situation for activists and journalists in countries like Pakistan. From activists and bloggers being abducted to journalists being killed, the situation looks horrendous. Social media is the only place where the people used to freely create vain echo chambers to  critique the government's actions. But they cannot do it without the fear of getting abducted or killed. The recently passed controversial cybercrimes law can be used to curtail dissent in the digital space as indicated by the interior minister Ahsan Iqbal. It is a slippery slope because of lack of accountability in such cases. While the state should be looking to curtail hate speech, it is looking to snub sane voices in the country.

Social media has transpired into a celebrated tool to delve in all sorts of political commentary, it has now become, more often than not, the only avenue for the mainstream populist narrative

The fact that social media has transpired into a celebrated tool to delve in all sorts of political commentary, it has now become, more often than not, the only tool to mainstream populist narrative. The make-or-break deal comes forth based on where the contradictory argument of the proposed ideology rests. Political leaders who once relied on door-to-door knocks for constituency now pitch - at least a part of - to their electoral proposals online. The former US president Barack Obama had a budget of $16 million to campaign on the internet. His election campaign focused on at least 15 different social media platforms along with other hit-hard online strategies indicating that it worked better than the Republican candidate John McCain's campaign.

While Obama may not be a populist leader,  the now-elected president Donald Trump gained popular vote through social media. The art of saying what the majority wants to hear is what a populist leader needs to have supremacy in and Trump knew it better than his rivals in the wake of religious and political turmoil in the United States. Because populist ideas don't  necessarily have to be ethical or in accordance with the humanitarian beliefs, Trump's constant badgering by great speeches and reinforcement of the campaign slogan while persecuting minorities on multiple media outlets was what worked in his favour.

In the context of Pakistan, Imran Khan, before the General Elections of 2013, successfully garnered support by communicating with particularly young citizens online about the injustices that they have been subjected to under Asif Ali Zardari's presidency. The vigilantes backed by Pakistan Tehreek-e-Insaf (PTI) actively took over every political debate online accounting for the populist ideology to thrive which was further evident by the 3-month long Azadi March in Islamabad and multiple successful rallies across Pakistan.

While Imran Khan's populist rhetoric was aimed at strengthening his own power by constant claims of rigging in the General Elections of 2013, the cry for removing the then Prime Minister Nawaz Sharif and subsequently demanding re-elections, Pakistan's founding pillars are particularly sentient of religious sentiments - a country that came into being to grant religious freedom to its occupants now rejects all beliefs except Islam. As religious monopoly is a populist expression of the Muslim majority, the political parties routinely target this sentiment to accumulate support, for example the recent protest by Tehreek-e-Labbaik Pakistan (TLP) to challenge the proposed amendments in the Elections Bill 2017.

Although the protest didn't stem from social media, it gained momentum online because of the populist idea that it was based on - Ahmadi persecution. It was noticed that the Twitter followers of the leader of TLP, Khaadim Hussain Rizvi, joined Twitter after the protest was mainstreamed, between October and November 2017. It was as though the protesters had found gold at the end of the rainbow and broadcasted their strength via Facebook live and direct online communication with people with the help of the large support that they have garnered in a matter of days, furthering the fact that Islam is the only way forward in Pakistan.

Populism was once largely believed to be instrumental to the social class and was initially introduced to contradict elite rulers, but in the present form it has  been translated into victimising the minorities - religious, social, cultural, political et al. Because the belief suits the sentiments of the majority, the demands stemming from it are taken at their face value while absolutely disregarding the minority. Pakistanis have particularly witnessed, and to rightly say that they have supported, multiple genocides against religious minorities on different instances because the ideologies satisfied the mostly Sunni majority. From the persecution of Hazara people and Shia genocide to Ahmedi killings to routinely Hindu and Christian persecution, "you're free to go to your mosques, temples, and churches" by Jinnah isn't valid in the land of pure anymore. Seventy years of Pakistan's history is evidence enough to indicate that conforming to the demands of the populists never plays out well in the favour of the already marginalised groups of society.

While pure populism is widely critiqued in the political context for its poor chances of success, populist movements have occasionally been ethical in principle where the sole purpose of initiating the movement was to acknowledge minority rights or the rights of those who live on the margins. For example, Podemos, the populist Spanish party, is advocating to grant voting rights to immigrants; the regulations around same sex marriages have received favourable popular votes in the countries where it's legal now.

The role of social media has been remarkable in the modern day left-wing populism. Women's March that took place earlier this year in the United States the same day Donald Trump took his oath as the president was solely organised through Facebook. While the narrative wasn't entirely populist, it gained popularity online and gathered millions of women from around the world against something they believed was worth fighting for - indicating towards the potential of online media to initiate social change.

Online media has the power to mould opinions and reinforce ideologies as its occupants deem fit. Adding populism to the evolving digital dynamics empowers people to be the apologists of extremist rhetoric, and it also has the potential of popularising debate around minority rights in conventional conversations. Whilst governments around the world use the internet to advance their ideologies in the modern days, yet it's one of the biggest threats to their authoritarianism resulting in the routinely attempts to stifle dissent on these mediums through disproportionate measures like internet shutdowns - partial and absolute, forced abductions of sane voices against injustices of oligarchy, targeting the religious sentiments of the masses to obscure minority discourse, and restraining free speech on account of it being hate speech or against national security.")

t <- make_features(df_test) %>% select(!c("type", "id"))
t <- as.h2o(t)
as.tibble(h2o.predict(gbm_model, t))
