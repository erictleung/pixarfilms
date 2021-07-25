# Pixar films head and tail

    Code
      first_last(pixar_films)
    Output
      # A tibble: 20 x 5
         number film            release_date run_time film_rating
         <chr>  <chr>           <date>          <dbl> <chr>      
       1 1      Toy Story       1995-11-22         81 G          
       2 2      A Bug's Life    1998-11-25         95 G          
       3 3      Toy Story 2     1999-11-24         92 G          
       4 4      Monsters, Inc.  2001-11-02         92 G          
       5 5      Finding Nemo    2003-05-30        100 G          
       6 6      The Incredibles 2004-11-05        115 PG         
       7 7      Cars            2006-06-09        117 G          
       8 8      Ratatouille     2007-06-29        111 G          
       9 9      WALL-E          2008-06-27         98 G          
      10 10     Up              2009-05-29         96 PG         
      11 18     Cars 3          2017-06-16        102 G          
      12 19     Coco            2017-11-22        105 PG         
      13 20     Incredibles 2   2018-06-15        118 PG         
      14 21     Toy Story 4     2019-06-21        100 G          
      15 22     Onward          2020-03-06        102 PG         
      16 23     Soul            2020-12-25        100 PG         
      17 24     Luca            2021-06-18        151 N/A        
      18 25     Turning Red     2022-03-11         NA N/A        
      19 26     Lightyear       2022-06-17         NA N/A        
      20 27     <NA>            2023-06-16        155 Not Rated  

---

    Code
      first_last(pixar_people)
    Output
      # A tibble: 20 x 3
         film        role_type    name           
         <chr>       <chr>        <chr>          
       1 Toy Story   Director     John Lasseter  
       2 Toy Story   Screenwriter Joel Cohen     
       3 Toy Story   Screenwriter Alec Sokolow   
       4 Toy Story   Screenwriter Andrew Stanton 
       5 Toy Story   Screenwriter Joss Whedon    
       6 Toy Story   Storywriter  Pete Docter    
       7 Toy Story   Storywriter  Lasseter       
       8 Toy Story   Storywriter  Joe Ranft      
       9 Toy Story   Storywriter  Stanton        
      10 Toy Story   Producer     Bonnie Arnold  
      11 Turning Red Director     Domee Shi      
      12 Turning Red Screenwriter <NA>           
      13 Turning Red Storywriter  <NA>           
      14 Turning Red Producer     Lindsey Collins
      15 Turning Red Musician     <NA>           
      16 Lightyear   Director     Angus MacLane  
      17 Lightyear   Screenwriter <NA>           
      18 Lightyear   Storywriter  <NA>           
      19 Lightyear   Producer     Galyn Susman   
      20 Lightyear   Musician     <NA>           

---

    Code
      first_last(genres)
    Output
      # A tibble: 20 x 2
         film         genre    
         <chr>        <chr>    
       1 Toy Story    Animation
       2 Toy Story    Adventure
       3 Toy Story    Comedy   
       4 Toy Story    Family   
       5 Toy Story    Fantasy  
       6 A Bug's Life Animation
       7 A Bug's Life Adventure
       8 A Bug's Life Comedy   
       9 A Bug's Life Family   
      10 Toy Story 2  Animation
      11 Turning Red  Animation
      12 Turning Red  Adventure
      13 Turning Red  Comedy   
      14 Turning Red  Family   
      15 Turning Red  Fantasy  
      16 Lightyear    Animation
      17 Lightyear    Adventure
      18 Lightyear    Family   
      19 Lightyear    Fantasy  
      20 Lightyear    Sci-Fi   

---

    Code
      first_last(box_office[, c("film", "budget")])
    Output
      # A tibble: 20 x 2
         film                 budget
         <chr>                 <dbl>
       1 Toy Story          30000000
       2 A Bug's Life      120000000
       3 Toy Story 2        90000000
       4 Monsters, Inc.    115000000
       5 Finding Nemo       94000000
       6 The Incredibles    92000000
       7 Cars              120000000
       8 Ratatouille       150000000
       9 WALL-E            180000000
      10 Up                175000000
      11 Inside Out        175000000
      12 The Good Dinosaur 175000000
      13 Finding Dory      200000000
      14 Cars 3            175000000
      15 Coco              175000000
      16 Incredibles 2     200000000
      17 Toy Story 4       200000000
      18 Onward            175000000
      19 Soul              175000000
      20 Luca                     NA

---

    Code
      first_last(box_office[, box_office_cols])
    Output
      # A tibble: 20 x 4
         film              box_office_us_canada box_office_other box_office_worldwide
         <chr>                            <dbl>            <dbl>                <dbl>
       1 Toy Story                    191796233        181757800            373554033
       2 A Bug's Life                 162798565        200460294            363258859
       3 Toy Story 2                  245852179        251522597            497374776
       4 Monsters, Inc.               289916256        342400393            632316649
       5 Finding Nemo                 339714978        531300000            871014978
       6 The Incredibles              261441092        370165621            631606713
       7 Cars                         244082982        217900167            461983149
       8 Ratatouille                  206445654        417280431            623726085
       9 WALL-E                       223808164        297503696            521311860
      10 Up                           293004164        442094918            735099082
      11 Inside Out                   356461711        501149463            857611174
      12 The Good Dinosaur            123087120        209120551            332207671
      13 Finding Dory                 486295561        542275328           1028570889
      14 Cars 3                       152901115        231029541            383930656
      15 Coco                         209726015        597356181            807082196
      16 Incredibles 2                608581744        634223615           1242805359
      17 Toy Story 4                  434038008        639356585           1073394593
      18 Onward                        61555145         80394976            141950121
      19 Soul                                NA        135435315            135435315
      20 Luca                                NA               NA                   NA

---

    Code
      first_last(public_response)
    Output
      # A tibble: 20 x 5
         film              rotten_tomatoes metacritic cinema_score critics_choice
         <chr>                       <dbl>      <dbl> <chr>                 <dbl>
       1 Toy Story                     100         95 A                        NA
       2 A Bug's Life                   92         77 A                        NA
       3 Toy Story 2                   100         88 A+                      100
       4 Monsters, Inc.                 96         79 A+                       92
       5 Finding Nemo                   99         90 A+                       97
       6 The Incredibles                97         90 A+                       88
       7 Cars                           74         73 A                        89
       8 Ratatouille                    96         96 A                        91
       9 WALL-E                         95         95 A                        90
      10 Up                             98         88 A+                       95
      11 Inside Out                     98         94 A                        93
      12 The Good Dinosaur              76         66 A                        75
      13 Finding Dory                   94         77 A                        89
      14 Cars 3                         69         59 A                        66
      15 Coco                           97         81 A+                       89
      16 Incredibles 2                  93         80 A+                       86
      17 Toy Story 4                    97         84 A                        94
      18 Onward                         88         61 A-                       79
      19 Soul                           96         83 <NA>                     93
      20 Luca                           NA         NA <NA>                     NA

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
      11 Toy Story 4  Animated Feature    Won                     
      12 Toy Story 4  Original Screenplay Ineligible              
      13 Toy Story 4  Original Song       Nominated               
      14 Onward       Animated Feature    Nominated               
      15 Onward       Adapted Screenplay  Ineligible              
      16 Soul         Animated Feature    Won                     
      17 Soul         Adapted Screenplay  Ineligible              
      18 Soul         Original Score      Won                     
      19 Soul         Sound Editing       Nominated               
      20 Soul         Sound Mixing        Nominated               

