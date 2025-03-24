# Pixar films head and tail

    Code
      first_last(pixar_films)
    Output
      # A tibble: 20 x 6
         number film            release_date run_time film_rating plot                
          <int> <chr>           <date>          <dbl> <chr>       <chr>               
       1      1 Toy Story       1995-11-22         81 G           "A cowboy doll is p~
       2      2 A Bug's Life    1998-11-25         95 G           "A misfit ant, look~
       3      3 Toy Story 2     1999-11-24         92 G           "When Woody is stol~
       4      4 Monsters, Inc.  2001-11-02         92 G           "In order to power ~
       5      5 Finding Nemo    2003-05-30        100 G           "After his son is c~
       6      6 The Incredibles 2004-11-05        115 PG          "While trying to le~
       7      7 Cars            2006-06-09        116 G           "On the way to the ~
       8      8 Ratatouille     2007-06-29        111 G           "A rat who can cook~
       9      9 WALL-E          2008-06-27         98 G           "A robot who is res~
      10     10 Up              2009-05-29         96 PG          "78-year-old Carl F~
      11     19 Coco            2017-11-22        105 PG          "Aspiring musician ~
      12     20 Incredibles 2   2018-06-15        118 PG          "The Incredibles fa~
      13     21 Toy Story 4     2019-06-21        100 G           "When a new toy cal~
      14     22 Onward          2020-03-06        102 PG          "Teenage elf brothe~
      15     23 Soul            2020-12-25        100 PG          "Joe is a middle-sc~
      16     24 Luca            2021-06-18         95 PG          "On the Italian Riv~
      17     25 Turning Red     2022-03-11        100 PG          "A thirteen-year-ol~
      18     26 Lightyear       2022-06-17        105 PG          "While spending yea~
      19     27 Elemental       2023-06-16        101 PG          "Follows Ember and ~
      20     28 Inside Out 2    2024-06-14         96 PG          "A sequel that feat~

---

    Code
      first_last(pixar_people)
    Output
      # A tibble: 20 x 3
         film         role_type    name            
         <chr>        <chr>        <chr>           
       1 Toy Story    Director     John Lasseter   
       2 Toy Story    Musician     Randy Newman    
       3 Toy Story    Producer     Bonnie Arnold   
       4 Toy Story    Producer     Ralph Guggenheim
       5 Toy Story    Screenwriter Joel Cohen      
       6 Toy Story    Screenwriter Alec Sokolow    
       7 Toy Story    Screenwriter Andrew Stanton  
       8 Toy Story    Screenwriter Joss Whedon     
       9 Toy Story    Storywriter  Pete Docter     
      10 Toy Story    Storywriter  John Lasseter   
      11 Elemental    Storywriter  Brenda Hsueh    
      12 Elemental    Storywriter  Kat Likkel      
      13 Elemental    Storywriter  Peter Sohn      
      14 Inside Out 2 Director     Kelsey Mann     
      15 Inside Out 2 Musician     Andrea Datzman  
      16 Inside Out 2 Producer     Mark Nielsen    
      17 Inside Out 2 Screenwriter Dave Holstein   
      18 Inside Out 2 Screenwriter Meg LeFauve     
      19 Inside Out 2 Storywriter  Meg LeFauve     
      20 Inside Out 2 Storywriter  Kelsey Mann     

---

    Code
      first_last(genres)
    Output
      # A tibble: 20 x 3
         film         category value               
         <chr>        <chr>    <chr>               
       1 Toy Story    Genre    Adventure           
       2 Toy Story    Genre    Animation           
       3 Toy Story    Genre    Comedy              
       4 Toy Story    Subgenre Buddy Comedy        
       5 Toy Story    Subgenre Computer Animation  
       6 Toy Story    Subgenre Fantasy             
       7 Toy Story    Subgenre Supernatural Fantasy
       8 Toy Story    Subgenre Urban Adventure     
       9 A Bug's Life Genre    Adventure           
      10 A Bug's Life Genre    Animation           
      11 Elemental    Subgenre Romance             
      12 Elemental    Subgenre Urban Adventure     
      13 Inside Out 2 Genre    Adventure           
      14 Inside Out 2 Genre    Animation           
      15 Inside Out 2 Genre    Comedy              
      16 Inside Out 2 Subgenre Coming-of-Age       
      17 Inside Out 2 Subgenre Computer Animation  
      18 Inside Out 2 Subgenre Quest               
      19 Inside Out 2 Subgenre Teen Comedy         
      20 Inside Out 2 Subgenre Teen Drama          

---

    Code
      first_last(box_office[, c("film", "budget")])
    Output
      # A tibble: 20 x 2
         film               budget
         <chr>               <dbl>
       1 Toy Story        30000000
       2 A Bug's Life    120000000
       3 Toy Story 2      90000000
       4 Monsters, Inc.  115000000
       5 Finding Nemo     94000000
       6 The Incredibles  92000000
       7 Cars            120000000
       8 Ratatouille     150000000
       9 WALL-E          180000000
      10 Up              175000000
      11 Coco            175000000
      12 Incredibles 2   200000000
      13 Toy Story 4     200000000
      14 Onward          175000000
      15 Soul            150000000
      16 Luca                   NA
      17 Turning Red     175000000
      18 Lightyear       200000000
      19 Elemental       200000000
      20 Inside Out 2    200000000

---

    Code
      first_last(box_office[, box_office_cols])
    Output
      # A tibble: 20 x 4
         film            box_office_us_canada box_office_other box_office_worldwide
         <chr>                          <dbl>            <dbl>                <dbl>
       1 Toy Story                  223225679        171210907            394436586
       2 A Bug's Life               162798565        200460294            363258859
       3 Toy Story 2                245852179        265506097            511358276
       4 Monsters, Inc.             255873250        272900000            528773250
       5 Finding Nemo               339714978        531300000            871014978
       6 The Incredibles            261441092        370001000            631442092
       7 Cars                       244082982        217900167            461983149
       8 Ratatouille                206445654        417280431            623726085
       9 WALL-E                     223808164        297503696            521311860
      10 Up                         293004164        442094918            735099082
      11 Coco                       210460015        604181157            814641172
      12 Incredibles 2              608581744        634223615           1242805359
      13 Toy Story 4                434038008        639356585           1073394593
      14 Onward                      61555145         80384897            141940042
      15 Soul                          946154        120957731            121903885
      16 Luca                         1324302         49788012             51112314
      17 Turning Red                  1399001         20414357             21813358
      18 Lightyear                  118307188        108118232            226425420
      19 Elemental                  154426697        342017611            496444308
      20 Inside Out 2               652980194       1045050771           1698030965

---

    Code
      first_last(public_response)
    Output
      # A tibble: 20 x 8
         film            rotten_tomatoes_score rotten_tomatoes_counts metacritic_score
         <chr>                           <dbl>                  <dbl>            <dbl>
       1 Toy Story                         100                     96               95
       2 A Bug's Life                       92                     91               78
       3 Toy Story 2                       100                    172               88
       4 Monsters, Inc.                     96                    199               79
       5 Finding Nemo                       99                    270               90
       6 The Incredibles                    97                    250               90
       7 Cars                               75                    204               73
       8 Ratatouille                        96                    253               96
       9 WALL-E                             95                    261               95
      10 Up                                 98                    297               88
      11 Coco                               97                    357               81
      12 Incredibles 2                      93                    390               80
      13 Toy Story 4                        97                    459               84
      14 Onward                             88                    350               64
      15 Soul                               95                    360               83
      16 Luca                               91                    303               71
      17 Turning Red                        95                    289               83
      18 Lightyear                          74                    319               60
      19 Elemental                          73                    262               58
      20 Inside Out 2                       90                    313               73
      # i 4 more variables: metacritic_counts <dbl>, cinema_score <chr>,
      #   imdb_score <dbl>, imdb_counts <dbl>

---

    Code
      first_last(academy)
    Output
      # A tibble: 20 x 3
         film         award_type          status                  
         <chr>        <chr>               <chr>                   
       1 Toy Story    Animated Feature    Award not yet introduced
       2 Toy Story    Original Screenplay Nominated               
       3 Toy Story    Adapted Screenplay  Ineligible              
       4 Toy Story    Original Score      Nominated               
       5 Toy Story    Original Song       Nominated               
       6 Toy Story    Other               Won Special Achievement 
       7 A Bug's Life Animated Feature    Award not yet introduced
       8 A Bug's Life Adapted Screenplay  Ineligible              
       9 A Bug's Life Original Score      Nominated               
      10 Toy Story 2  Animated Feature    Award not yet introduced
      11 Soul         Sound Editing       Nominated               
      12 Soul         Sound Mixing        Nominated               
      13 Luca         Animated Feature    Nominated               
      14 Luca         Adapted Screenplay  Ineligible              
      15 Turning Red  Animated Feature    Nominated               
      16 Turning Red  Adapted Screenplay  Ineligible              
      17 Lightyear    Original Screenplay Ineligible              
      18 Elemental    Animated Feature    Nominated               
      19 Elemental    Adapted Screenplay  Ineligible              
      20 Inside Out 2 Original Screenplay Ineligible              

