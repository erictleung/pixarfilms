from datetime import datetime
from airflow import DAG
from airflow.providers.standard.operators.bash import BashOperator
from airflow.utils.task_group import TaskGroup

default_args = {
    "owner": "admin",
}

with DAG(
    dag_id='pull_pixar_films_data',
    description='Pipeline for pulling and processing Pixar films data',
    start_date=datetime(2026, 3, 1),
    schedule='@once',
    default_args=default_args,
    tags=['pixar', 'rstats', 'webscraping']
) as dag:
    with TaskGroup("pull_tasks") as pull_tasks:
        p_wiki = BashOperator(
            task_id="pull_wikipedia", 
            bash_command="Rscript data-raw/scripts/pull_wikipedia_data.R"
        )
        p_omdb = BashOperator(
            task_id="pull_omdb", 
            bash_command="Rscript data-raw/scripts/pull_omdb_data.R"
        )
        p_rt = BashOperator(
            task_id="pull_rt", 
            bash_command="Rscript data-raw/scripts/pull_rt_ratings.R"
        )

    with TaskGroup("clean_tasks") as clean_tasks:
        c_films = BashOperator(
            task_id="clean_films", 
            bash_command="Rscript data-raw/scripts/clean_pixar_films.R"
        )
        c_people = BashOperator(
            task_id="clean_people", 
            bash_command="Rscript data-raw/scripts/clean_pixar_people.R"
        )
        c_box = BashOperator(
            task_id="clean_box_office", 
            bash_command="Rscript data-raw/scripts/clean_box_office.R"
        )
        c_pub = BashOperator(
            task_id="clean_public_response", 
            bash_command="Rscript data-raw/scripts/clean_public_response.R"
        )
        c_acad = BashOperator(
            task_id="clean_academy", 
            bash_command="Rscript data-raw/scripts/clean_academy.R"
        )
        
        c_films >> c_people >> c_box >> c_pub >> c_acad

    pull_tasks >> clean_tasks
