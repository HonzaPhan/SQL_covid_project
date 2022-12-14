<h1> SQL covid project from Engeto </h1>

<p>
I am trying to determine the factors that influence the speed of the spread of the coronavirus at the level of individual states. The resulting data will be panel data, the keys will be state (country) and day (date). <br>
I will evaluate a model that will explain the daily increase in infected people in individual countries. <br>
However, the number of infected people alone is of no use to me - it is also necessary to take into account the number of tests carried out and the population of the given state. It is then possible to create a suitable explained variable from these three variables. I want to explain the daily number of infected people using variables of several types. Each column in the table will represent one variable.
</p>

<h3> We want to get the following columns: </h3>
<ol>
<li><u>Time variables</u></li>
    <ul>
      <li>binary variable for weekend / weekday</li>
      <li>season of the day (encode as 0 to 3)</li>
    </ul>
<br>
<li><u>State-specific variables</u></li>
    <ul>
      <li>population density - in states with a higher population density, the infection can spread faster</li>
      <li>GDP per capita - we will use it as an indicator of the state's economic maturity</li>
      <li>GINI coefficient - does wealth inequality affect the spread of the coronavirus?</li>
      <li>child mortality - we will use it as an indicator of the quality of healthcare</li>
      <li>median age of population in 2018 - states with older populations may be more affected</li>
      <li>shares of individual religions - we will use it as a proxy variable for cultural specifics. For each religion in a given state, I would like the percentage               of its adherents to the total population</li>
      <li>the difference between life expectancy in 1965 and in 2015 - countries in which rapid development took place may react differently than countries that have               been developed for a longer time</li>
    </ul>
<br>
<li>Weather (affects people's behavior and also the ability of the virus to spread)</li>
    <ul>
      <li>average day (not night!) temperature</li>
      <li>the number of hours on a given day when precipitation was non-zero</li>
      <li>maximum wind gusts during the day</li>
    </ul>
</ol>  
