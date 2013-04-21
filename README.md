WhizzKid
==========================
A Trivia Game using websockets, BackboneJS on Sinatra

GETTING STARTED
-------------------

Start the game server:

<pre>
bundle
ruby config.ws
</pre>

Start the web client / tile provider:

<pre>
bundle
thin start
</pre>

QUESTIONS
------------------

Questions are stored in yaml files in the questions folder. Each file is named by topic.
On creation of a new round, all requested topics are matched, questions are read, shuffled, then sampled to generate
the round's question set.

NO TESTS
------------------
Whoohoo! This was built at speed - tests are few.
