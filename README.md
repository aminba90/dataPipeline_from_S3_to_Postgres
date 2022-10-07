# Assignment task for Data Engineer

## Introduction

Assume you are a Data Engineer working at upday. 

You are in close communication with our Business Intelligence team and you need to provide that data that they need for their daily duty.

At the same time, you have the necessary knowledge to find and fetch the raw data that upday receives from the app and make it ready for the BI team needs.

The scope of this task is build everything that is between raw data and BI tables.## Introduction

Assume you are a Data Engineer working at upday. 

You are in close communication with our Business Intelligence team and you need to provide that data that they need for their daily duty.

At the same time, you have the necessary knowledge to find and fetch the raw data that upday receives from the app and make it ready for the BI team needs.

The scope of this task is build everything that is between raw data and BI tables.

## Assignment
The BI team in Upday requires 2 tables:
* article_performance: aggregating simple stats on how the article has performed
* user_performance: aggregating simple stats on how the user interacted with the app

<p align="center">
  <img src="https://upday-data-assignment.s3-eu-west-1.amazonaws.com/upday.jpeg" width="250" alt="Top news card">
</p>

The data is available at https://s3.console.aws.amazon.com/s3/buckets/upday-data-assignment/lake/ as tsv files. Following are the three expected tsv files
1. https://upday-data-assignment.s3.eu-west-1.amazonaws.com/lake/2019-02-15.tsv
2. https://upday-data-assignment.s3.eu-west-1.amazonaws.com/lake/2019-02-16.tsv
3. https://upday-data-assignment.s3.eu-west-1.amazonaws.com/lake/2019-02-17.tsv

Following are few more details regarding the s3-data
  * Each line in the files represent a collected event, the 1st line is the header to help interpret the schema
  * EVENT_NAME column represents the type of event collected 
    * top_news_card_viewed -> A card from Top news section has been viewed by the user
    * my_news_card_viewed -> A card from My news section has been viewed by the user
    * article_viewed -> The user clicked on the card and viewed the article in the app's web viewer
  * The Attributes column is the event payload as a JSON text
    * id = id of the article
    * category = category of the article
    * url
    * title 
    * etc...

The two tables should be created in the Postgres DB that is brought up by executing the docker-compose script in the project folder. They should look as the examples below:

<u>article_performance table</u>

| article_id  | date         | title           | category   | card_views | article_views |
|-------------|--------------|-----------------|------------|------------|---------------|
| id1         |  2020-01-01  | Happy New Year! |  Politics  |  1000      |    22         |

<u>user_performance table</u>

| user_id     | date         | ctr   |
|-------------|--------------|-------|
| id1         |  2020-01-01  |0.15   |

* ctr(click through rate) = number of articles viewed / number of cards viewed
* load the files directly from S3 instead of manually copying them locally 
* create staging tables as necessary for any intermediate steps in the process

## Instructions
You should make a pull request to this repository containing the solution. If you need to clarify any point of your solution, please include an explanation in the PR description.

What we expect:
* The code implementing the ETL logic, triggered from the `run.py` script
* Extension of the currently existing `Dockerfile` (only if needed)
* Tests, with instructions on how to run them

Some more details:
* The docker compose file will create a Postgres container already connected to the ETL container. You should use that Postgres instance for storing data models and solution.
* The task reviewer will only run `docker-compose up` and wait for the container to exit, 
* After the command prints `data-assignment-task_etl_1 exited with code 0`, the database is expected to be in its final state, with the solution to the task.

The task will be evaluated based on:
* Correctness of the final result
* Readability of the code(logging, error control, comments)
* Architecture of the solution
* Tests (full coverage is not required, you should mainly test the critical parts of the code)

To access the data in S3:
* Create new AWS account: https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/
* Access keys to programatically access S3 objects: https://docs.aws.amazon.com/powershell/latest/userguide/pstools-appendix-sign-up.html
* Access S3 objects from python: https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/s3.html

# Solution
This is a solution to load a collection of tab separated logs from AWS s3 into Postgres db with respect to some requested corrections and transformations which has been done by Pandas.It located inside ```PandasSolution``` folder.

Also, I provided second solution for this task which I handled Transformation phase via Pyspark. I created a separate docker-compose for this and it needed to execute separately from original solution. It located inside ```SparkSolution``` folder.
### Disclaimer
This second solution has been provided just for proving the ability of working with Spark. Therefore, I haven't provided separated readme and unit test for this.

## Description
This is an End-to-End solution from "E"xtracting data from s3 bucket, do some "T"ransformation and aggregation on intermediate data and finally "L"oad desired output into Postgres database.
To do this, various tools have been used, which are explained below. Also, Docker has been used to simulate the operating environment.
## Solution Architecture
To implement this code challenge, the following architecture is used, which the responsibility and the reason for use for each tool and library are described below.

<p align="center">
  <img src = "PandasSolution/images/architecture.png" width=80%>
</p>

### boto3
I have used boto3 in order to create a connection to AWS S3 and create resource for retrieving objects inside specific S3 bucket.A sample of record that has been retrieved from S3 bucket is as such as below:
``` tsv
2019-02-15 02:23:56.702 +0000	a5d11b9fa18f9aa588db0cdd3e681abb	my_news_card_viewed	0d60c3e2217985b1976b40a318692a7d	{    "category": "sports",    "id": "NWvaxVrGuf_rFC86pBZ_aA",    "noteType": "TRENDING_SOCIAL",    "orientation": "PORTRAIT",    "position": "1",    "publishTime": "2019-02-14T18:51:00Z",    "sourceDomain": "bild.de",    "sourceName": "BILD",    "stream": "wtk",    "streamType": "my news",    "subcategories": [      "sports.football_domestic"    ],    "title": "Vor Frankfurts Europa-League-Spiel - Wüste Massen- Prügelei in Kiew",    "url": "https://m.bild.de/sport/fussball/fussball/vor-eintracht-frankfurts-europa-league-spiel-massen-pruegelei-in-kiew-60134848,view=amp.bildMobile.html?wtrid=upday"  }

```

for accessing to the S3 bucket, I needed to created an new security credential for my AWS user which is creates a new <b>access key ID</b> and <b>secret access key</b> for connecting to S3 bucket programatically. I am going to read all tsv files inside <b>/lake</b> folder and concatenate them inside a single Pandas dataframe. A reason for this is that I found quite a few files inside this folder and I choose to load all of them inside single entity as it won't cause any trouble or any raising exceptions.
In any case if we want to load huge number of files from a single or multiple direcotries, It would be better workaround if we do it in a batch form and load files in a specific batch of files with specific thresholds.


### Pandas
pandas is a software library written for the Python programming language for data manipulation and analysis. In particular, it offers data structures and operations for manipulating numerical tables and time series. It is free software released under the three-clause BSD license.

I chose Pandas for data manipulation and transformation, because it's very easy to use and it provided an effecient way of working with file formatted data. Also it gives you the ability to perform any kinds of transformation and aggregation on data with a little of coding.
All Extract and Transform phases of this challenge has been done by Pandas and it was really useful for me.After all data wrangling tasks, 2 Pandas dataframe will be prepared for inserting them into final Postgres tables.

### Pyspark
As I mentioned before, for doing data cleansing and data transformation,I have second option which is pyspark and I used it to solve the main part of the code challenge. The reason for choosing PySpark is that it is very fast,scalable, and works very well for large-scale problems. Also, there are many provided libraries for different tasks that make the development process faster and better. Another reason is my experience in using Spark. I love Python and Spark :wink:.

As a way that Pandas works with dataframes, Spark is also have a almost similar behaviour. the dataframe concept inside Pyspark has those capabilities as what Pandas has and therefore coding is also some how similar. 

As data has been fetched from S3 bucket, I create a general spark dataframe and all following cleansing and transformations will be performed. At final stage, 2 different data frame will be prepared for inserting them into postgres DB.

### Postgres
As it requested inside task description, I had to provide dockerize Postgres instance which final output tables should been populated and prepared with final results. In order to have access to db object inside my Python code, I have used <b>SqlAlchemy</b> library. This is very easy to use and understand library for accesing to different types of databased from inside your Python environment. So with help of this library I tried to created db object and gain access to tables in order to check existence of them and also insert provided data inside our dataframes into respected tables.

As I assumed that this pipeline will be executed only once, I don't have any checks on insert duplicate records or any other pre-check processes. If it's needed to run this pipeline recurrently, we obliged to add those steps.

Also there is another improvment in our Loading phase in order to accelarate insert process. Instead of inserting into tables using Sqlalchemy, we can create a csv files from our dataframes and using ```COPY``` to load those files into tables. using this method will have significant impact on loading time.

### Docker

Docker is always a good choice for preparing the development 
environment and quickly implementing the software architecture and prototyping.

So I made a docker-compose file that provides all the tools and necessary connections. This file contains a special service called <b>postgres</b>, which is responsible for creating the Postgres db and also <b>etl</b> that is responsible for preparing a docker container for running our main ETL pipeline.

## Getting Started

This section explains how to run this App. I have tried to make it very simple. 

### Prerequisites
The required prerequisites are:

* Docker and docker-compose 3
* Internet connection to download required images

### Installation

Follow the steps below to run the App.

A.Pandas Solution:

A.1. running all containers
   ```sh
   $ cd /PandasSolution
   $ docker-compose up
   ```

A.2. After a few time, you would be able to see message ```pandassolution_etl_1 exited with code 0```

A.3. When you see this message, you can check the output results inside PostgresDB. For doing that you have to connect to Postgres container using docker exec command such as below:
```bash
docker exec -it updaydb bash
```
A.4. Inside docker container first you have to connect to Postgres instance using below command:
```bash
psql -h localhost -p 5432 -U postgres
```
and then connecting to upday DB using:
```bash
\c upday
```
Finally you can execute select statement to check the data of ```article_performance``` and ```user_performane``` table :
```bash
select * from user_performance;
select * from article_performance;
```

B.Spark Solution:

B.1. running all containers
   ```sh
   $ cd /SparkSolution
   $ docker-compose up
   ```

B.2. After a few time, you would be able to see message ```updayetl exited with code 0```

B.3. When you see this message, you can check the output results inside PostgresDB. For doing that you have to connect to Postgres container using docker exec command such as below:
```bash
docker exec -it updaydb bash
```
B.4. Inside docker container first you have to connect to Postgres instance using below command:
```bash
psql -h localhost -p 5432 -U postgres
```
and then connecting to upday DB using:
```bash
\c upday
```
Finally you can execute select statement to check the data of ```article_performance``` and ```user_performane``` table :
```bash
select * from user_performance;
select * from article_performance;
```

## Running unit test
in order to run different modules of this pipline, I created a unit tests for postgres and also S3 components as a proof for implementing a unit test. For this matter, I used <b>pytest</b> as standard library for writing test cases.
I have coded 3 test cases, which are consists of checking postgres db connection, checking that final tables populated by records and also checking availability of S3 connection.
after finishing the pipeline you can go to ```PandasSolution/tests/``` directory in a new shell and run test cases as below:
```bash
pytest
```
The output of running this should be like below:

<p align="center">
  <img src = "PandasSolution/images/test-output.png" width=100%>
</p>

## Stoping Services
Enter the following command to stop the containers:

```bash
$ docker-compose down -v
```

## Author

👤 **Amin Balouchi**

- Github: [@aminba90](https://github.com/aminba90)

## Version History
* 0.1
    * Initial Release
