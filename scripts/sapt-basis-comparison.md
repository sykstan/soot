<!-- ## R Markdown -->
<!-- This is an R Markdown document. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>. -->
<!-- When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document. You can embed an R code chunk like this: -->
<!-- ```{r cars} -->
<!-- summary(cars) -->
<!-- ``` -->
<!-- ## Including Plots -->
<!-- You can also embed plots, for example: -->
<!-- ```{r pressure, echo=FALSE} -->
<!-- plot(pressure) -->
<!-- ``` -->
<!-- Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot. -->
Datasets
--------

Before we try and get into the analysis, let's just be clear about what
data we have. The three main datasets are S22, S66, and ILs. I hesitate
to say IL174 because we actually have 191 systems, of which only 174
have CCSD(T)/CBS results, and 182 have SAPT2+3/aug-cc-pVDZ results, and
the cc-pVDZ are currently running at the time of writing (59 successful,
106 running, and 26 in queue). So you get an idea of how complicated
things can be. This is as much for my sake as for the reader's.

So, here are the results that we have, and their sources, and the files
I read them from.

### CCSD(T)/CBS

-   S88 -- S22\_S66\_MP2.xlsx, from Santiago and Jason(?)
-   IL -- jason-CBS.csv, which is originally from jason\_mp2\_il1P.xlsx,
    sheet CCSDT\_cp

### Comparison of SAPT2+3 components between basis sets

Here is the comparison between cc-pVDZ and aug-cc-pVDZ for SAPT2+3
components:

    ##              EnComp       MAE         SD          Min         Max
    ##  1:  delta.HF.r..2. 0.2521400 0.36582153  -1.30390372  1.51144640
    ##  2:  delta.HF.r..3. 0.2189818 0.35092612  -0.30092596  2.27676922
    ##  3:          Disp20 7.0667939 3.72319056   1.73538351 22.34053328
    ##  4:          Disp21 1.0971967 1.18488242  -6.39747764  0.06673942
    ##  5:    Disp22..SDQ. 0.3004994 0.41150130  -0.78851292  2.23186566
    ##  6:      Disp22..T. 1.7460153 1.05148429   0.31722979  6.16675744
    ##  7:          Disp30 0.3124786 0.21079894  -1.18842866 -0.03897137
    ##  8:      Dispersion 7.1037755 3.53241908   1.81719839 22.52609416
    ##  9:  Electrostatics 1.2681445 2.42179033 -18.95549939  1.27267649
    ## 10:        Elst10.r 1.2516566 2.45532802 -20.68561635  1.44539454
    ## 11:        Elst12.r 0.3995191 0.69018447  -3.37953992  3.01818128
    ## 12:        Elst13.r 0.2423865 0.33826983  -1.28806434  1.41084677
    ## 13:     Exch.Disp20 0.5705227 0.31420650  -1.75111829 -0.11042758
    ## 14:     Exch.Disp30 0.1325616 0.09742426   0.01379874  0.52776667
    ## 15: Exch.Ind.Disp30 0.3001358 0.29202328  -2.21091155  0.05455319
    ## 16:    Exch.Ind20.r 0.2003562 0.40428578  -2.14234906  2.39571191
    ## 17:      Exch.Ind22 0.1286240 0.12975598  -0.48849068  0.45659309
    ## 18:    Exch.Ind30.r 0.6823482 2.00118001 -17.51053743  4.06948848
    ## 19:          Exch10 0.6413437 1.23872641  -0.86224027 10.26954044
    ## 20:     Exch10.S.2. 0.6246406 1.20469771  -0.86860196  9.99405945
    ## 21:     Exch11.S.2. 0.4564818 0.34926694  -2.50499428 -0.06783024
    ## 22:     Exch12.S.2. 0.4236097 0.68150393  -1.43011035  4.97778992
    ## 23:        Exchange 0.7178169 1.31924502  -2.18870229  8.88264692
    ## 24:      Ind.Disp30 0.3105198 0.33032369  -0.36845219  2.47620832
    ## 25:         Ind20.r 0.6377006 0.82520510  -4.79204052  4.50088079
    ## 26:           Ind22 0.2450450 0.27049574  -0.79218652  1.06503213
    ## 27:         Ind30.r 0.6773511 1.94682775  -5.07246626 16.74521457
    ## 28:       Induction 0.7940046 0.96584247  -3.47512015  3.53438467
    ## 29:        Total.HF 0.8044119 1.75676902 -14.11630830  2.64450405
    ## 30:     Total.SAPT2 6.0572497 3.86521220  -4.94364387 19.91168435
    ## 31:   Total.SAPT2.3 6.7311581 3.89685938  -5.36305427 21.52013628
    ##              EnComp       MAE         SD          Min         Max

As you can see, there are some large deviations for Dispersion and
Electrostatics. For the minor terms, Disp20, Elst10.r, Exch.Ind30.r,
Exch10, Exch10.S.2., and Ind30.r are also large.
