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
      11     22 Onward          2020-03-06        102 PG          "Teenage elf brothe~
      12     23 Soul            2020-12-25        100 PG          "Joe is a middle-sc~
      13     24 Luca            2021-06-18         95 PG          "On the Italian Riv~
      14     25 Turning Red     2022-03-11        100 PG          "A thirteen-year-ol~
      15     26 Lightyear       2022-06-17        105 PG          "While spending yea~
      16     27 Elemental       2023-06-16        101 PG          "Follow Ember and W~
      17     28 Inside Out 2    2024-06-14         96 PG          "A sequel that feat~
      18     29 Elio            2025-06-20         98 PG          "Elio, a space fana~
      19     30 Hoppers         2026-03-06        104 PG          "A 19-year-old anim~
      20     31 Toy Story 5     2026-06-19        102 PG          "Woody, Buzz, Jessi~

---

    Code
      first_last(pixar_people)
    Output
      # A tibble: 20 x 3
         film        role_type    name            
         <chr>       <chr>        <chr>           
       1 Toy Story   Director     John Lasseter   
       2 Toy Story   Musician     Randy Newman    
       3 Toy Story   Producer     Bonnie Arnold   
       4 Toy Story   Producer     Ralph Guggenheim
       5 Toy Story   Screenwriter Joss Whedon     
       6 Toy Story   Screenwriter Andrew Stanton  
       7 Toy Story   Screenwriter Joel Cohen      
       8 Toy Story   Screenwriter Alec Sokolow    
       9 Toy Story   Storywriter  John Lasseter   
      10 Toy Story   Storywriter  Pete Docter     
      11 Hoppers     Storywriter  Daniel Chong    
      12 Hoppers     Storywriter  Jesse Andrews   
      13 Toy Story 5 Co-director  Kenna Harris    
      14 Toy Story 5 Director     Andrew Stanton  
      15 Toy Story 5 Musician     Randy Newman    
      16 Toy Story 5 Producer     Lindsey Collins 
      17 Toy Story 5 Producer     Jessica Choi    
      18 Toy Story 5 Screenwriter Andrew Stanton  
      19 Toy Story 5 Screenwriter Kenna Harris    
      20 Toy Story 5 Storywriter  Andrew Stanton  

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
      11 Hoppers      Subgenre High-Concept Comedy 
      12 Hoppers      Subgenre Sci-Fi              
      13 Hoppers      Subgenre Spy                 
      14 Toy Story 5  Genre    Adventure           
      15 Toy Story 5  Genre    Animation           
      16 Toy Story 5  Genre    Comedy              
      17 Toy Story 5  Subgenre Buddy Comedy        
      18 Toy Story 5  Subgenre Computer Animation  
      19 Toy Story 5  Subgenre Fantasy             
      20 Toy Story 5  Subgenre Urban Adventure     

---

    Code
      first_last(box_office[, c("film", "budget")])
    Output
      # A tibble: 20 x 2
         film               budget
         <chr>               <dbl>
       1 Toy Story        30000000
       2 A Bug's Life     40000000
       3 Toy Story 2      90000000
       4 Monsters, Inc.  115000000
       5 Finding Nemo     94000000
       6 The Incredibles  92000000
       7 Cars            120000000
       8 Ratatouille     150000000
       9 WALL-E          180000000
      10 Up              175000000
      11 Onward          200000000
      12 Soul            200000000
      13 Luca                   NA
      14 Turning Red     175000000
      15 Lightyear       200000000
      16 Elemental       200000000
      17 Inside Out 2    200000000
      18 Elio            150000000
      19 Hoppers         150000000
      20 Toy Story 5     250000000

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
      11 Onward                      61555145         80384897            141940042
      12 Soul                          946154        120957731            121903885
      13 Luca                         1324302         49788012             51112314
      14 Turning Red                  1399001         20414357             21813358
      15 Lightyear                  118307188        108118232            226425420
      16 Elemental                  154426697        342017611            496444308
      17 Inside Out 2               652980194       1045883622           1698863816
      18 Elio                        72987454         80810682            153798136
      19 Hoppers                    166010783        223537000            389547783
      20 Toy Story 5                461696126        604200000           1065896126

---

    Code
      first_last(public_response)
    Output
      # A tibble: 20 x 17
         film            rotten_tomatoes_score rotten_tomatoes_counts metacritic_score
         <chr>                           <dbl>                  <dbl>            <dbl>
       1 Toy Story                         100                    163               96
       2 A Bug's Life                       92                     90               78
       3 Toy Story 2                       100                    176               88
       4 Monsters, Inc.                     96                    191               79
       5 Finding Nemo                       99                    266               90
       6 The Incredibles                    97                    248               90
       7 Cars                               74                    198               73
       8 Ratatouille                        96                    251               96
       9 WALL-E                             95                    258               95
      10 Up                                 98                    291               88
      11 Onward                             88                    346               61
      12 Soul                               95                    361               83
      13 Luca                               91                    307               71
      14 Turning Red                        95                    291               83
      15 Lightyear                          74                    322               60
      16 Elemental                          73                    268               58
      17 Inside Out 2                       91                    329               73
      18 Elio                               83                    229               66
      19 Hoppers                            94                    225               73
      20 Toy Story 5                        92                    317               73
      # i 13 more variables: metacritic_counts <dbl>, cinema_score <chr>,
      #   imdb_score <dbl>, imdb_counts <dbl>,
      #   rotten_tomatoes_score_top_critics <dbl>,
      #   rotten_tomatoes_score_top_critics_votes <dbl>,
      #   rotten_tomatoes_popcorn_meter_score <dbl>,
      #   rotten_tomatoes_popcorn_meter_votes <dbl>,
      #   rotten_tomatoes_popcorn_meter_verified <dbl>, ...

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
      11 Luca         Adapted Screenplay  Ineligible              
      12 Turning Red  Animated Feature    Nominated               
      13 Turning Red  Adapted Screenplay  Ineligible              
      14 Lightyear    Original Screenplay Ineligible              
      15 Elemental    Animated Feature    Nominated               
      16 Elemental    Adapted Screenplay  Ineligible              
      17 Inside Out 2 Animated Feature    Nominated               
      18 Inside Out 2 Original Screenplay Ineligible              
      19 Elio         Animated Feature    Nominated               
      20 Elio         Adapted Screenplay  Ineligible              

