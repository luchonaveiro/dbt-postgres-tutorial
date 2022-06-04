# `dbt` Tutorial
[![Generic badge](https://img.shields.io/badge/dbt-1.1.0-blue.svg)](https://docs.getdbt.com/dbt-cli/cli-overview)
[![Generic badge](https://img.shields.io/badge/PostgreSQL-13-blue.svg)](https://www.postgresql.org/)
[![Generic badge](https://img.shields.io/badge/Python-3.7-blue.svg)](https://www.python.org/)
[![Generic badge](https://img.shields.io/badge/Docker-20.10.6-blue.svg)](https://www.docker.com/)

`dbt` tutorial taken from the different [dbt courses](https://courses.getdbt.com/collections), using `PostgreSQL` as the data warehouse. There you are going to find the following 5 courses:
- [dbt Fundamentals](https://courses.getdbt.com/courses/fundamentals)
- [Jinja, Macros, Packages](https://courses.getdbt.com/courses/jinja-macros-packages)
- [Advanced Materializations](https://courses.getdbt.com/courses/advanced-materializations)
- [Analyses and Seeds](https://courses.getdbt.com/courses/analyses-seeds)
- [Refactoring SQL for Modularity](https://courses.getdbt.com/courses/refactoring-sql-for-modularity)

For this tutorial, I adapted a little bit the `profiles.yml` file, to use a local `PostgreSQL` database, instead of using `Redshift`, `Snowflake`, `BigQuery` or `Databricks`.

## Project Set Up
First we should download the [.csv files](https://gist.github.com/coapacetic/d3f20c2e727dc96b830c86da5ad93678) that we are going to insert to the DB. We should download this data on the `db/data` directory.

Now we can create the PostgreSQL database an insert the dowbloaded data to get along with the tutorial. To do so, just change directory to `db` and execute:
```
$ docker compose up
```
This command will spin a PostgreSQL database on localhost and port 5432, and will create the `raw` database, and create and insert the `.csv` files to the following tables:
- `jaffle_shop.customers`
- `jaffle_shop.orders`
- `stripe.payments`

Once the database is ready, we can install `dbt` and initiate the `dbt` project:
```
$ pip3 install dbt-postgres==1.1.0
$ dbt init jaffle_shop
```

Now we should create the `profiles.yml` file on the `jaffle_shop` directory. The file should look like this:
```
config:
    use_colors: True 
jaffle_shop:
  outputs:
    dev:
      type: postgres
      threads: 1
      host: localhost
      port: 5432
      user: "docker"
      pass: "docker"
      dbname: raw
      schema: dev
    prod:
      type: postgres
      threads: 1
      host: localhost
      port: 5432
      user: "docker"
      pass: "docker"
      dbname: raw
      schema: analytics
  target: dev
```

To run `dbt`, we just execute, inside `jaffle_shop` directory
```
$ dbt run --profiles-dir .
```
This will run all the modles defined on the `models` directory.

In case you only want to run 1 model, you can execute
```
$ dbt run -m FILE_NAME --profiles-dir .
```

In case you only want to run 1 model and all the other ones that depends on it, you can execute
```
$ dbt run -m FILE_NAME+ --profiles-dir .
```

In case you only want to run 1 model and all the previous ones, you can execute
```
$ dbt run -m +FILE_NAME --profiles-dir .
```

In case you only want to run 1 model, all the previous ones and all the dependencies, you can execute
```
$ dbt run -m +FILE_NAME+ --profiles-dir .
```

To compile the queries, we can run:
```
$ dbt compile --profiles--dir .
```
That command will save the compiled queries on `target/compiled/PROJECT_NAME/models` directory

## dbt Fundamentals

### Naming Conventions
- source: raw tables that are stored form differnet processes on the warehouse.
- staging: 1to1 with source table, where some minimal transformations can be done.
- intermediate: models between staging and final models (always built on staging)
    - fact tables: things that are ocurring or have ocurred (events)
    - dimension tables: things that "are" or "exists" (people, places, etc)

### Project Reorganization
- create folders inside `models` directory:
    - staging: will store all th staging models
        - one folder per schema, onde file per table
    - mart: will store the final outputs aht are modeled.
        - a best practice is to create a folder inside mart, per area (marketing, finance, etc)
- use the `ref` function to reference to another model (a staging table or a dim table or a fcat table)

Changes en `dbt_project.yml`:
- here you can choose the materialization of each dataproduct (table, view, incremental). The default one is view. This option can be overriden on each `.sql` file.

### Data Sources
- configure the source data only once in a `.yml` file
- we use the `source` function to reference to the source table from the `.yml`
- visualize the raw tables in the lineage on dbt Cloud UI

### Tests
The tests are data validations that are performed after the data is loaded to the warehouse. On `dbt` there are two types of tests:
- singular tests:
    - they are defined as a `.sql` file inside the `tests` directory
    - super specific tests that are olny valid for one model in particular
- generic tests:
    they are defined on a `.yml` file inside the `models` directory, for particular tables/columns
    - unique
    - not null
    - accepted_values
    - relationships
- you can also test the source tables, by adding the generic tests on the source .yml, or by creaeting the custom `.sql` query on `tests` directory
- additional testing can be imported through packages or write ypur custom generic tests
- Execute `dbt test --profiles-dir .` to run all generic and singular tests in your project.
- Execute `dbt test --select test_type:generic --profiles-dir .` to run only generic tests in your project.
- Execute `dbt test --select test_type:singular --profiles-dir .` to run only singular tests in your project.
- Execute `dbt test --select one_specific_model --profiles-dir .` to run only one specific model

### Documentation
- doc blocks: you can use only on doc block per `.md` file, or many doc blocks on one single `.md` file.
```
{% docs NAME %}
description
...
{% enddocs %}
```
you have to create a `.md` file with the documentation, and then reference it on the `model.yml` file, for example: `description: "{{ doc('order_status') }}"`
to generate the docs, execute: 
```
$ dbt docs generate --profiles-dir .
```

This command will create a `index.html` file on `target` directory. 

We can run a `nginx` server to expose this webpage to see the data documentation (run this from inside `dbt-postgres/dbt_findamentals/jaffle_shop` directory). This will use the [dockersamples/static-site](https://hub.docker.com/r/dockersamples/static-site/) Docker image.
```
$ docker run --name dbt_docs --rm /
-d -v $PWD/target:/usr/share/nginx/html /
-p 8888:80 dockersamples/static-site

$ dbt docs generate --profiles-dir .
```

This will generate the docs webpage available on `localhost:8888`, where we can see the all the define documentation, the dependencies, the lineage graph, and everything we need to make all the data model much more clear.

## Jinja, Macros, and Packages

### Jinja
- Python templating language
- Brings functional aspects to SQL

[Jinja Documentation](https://jinja.palletsprojects.com/page/templates/)

We have been using examples of Jinja, when using the `ref` function:
```
{{ ref(stg_customers) }}
```

There are three Jinja delimiters to be aware of in Jinja.

- `{% … %}` is used for statements. These perform any function programming such as setting a variable or starting a for loop.
- `{{ … }}` is used for expressions. These will print text to the rendered file. In most cases in dbt, this will compile your Jinja to pure SQL.
- `{# … #}` is used for comments. This allows us to document our code inline. This will not be rendered in the pure SQL that you create when you run dbt compile or dbt run.

A few helpful features of Jinja include dictionaries, lists, if/else statements, for loops, and macros.

Also we can use variables, for instance, to use some values to filter. We can use the `{{ var ('...') }}` macro for that, and define the variable name on the  `dbt_project.yml` file:

```
vars:
  # The `date` variable will be accessible in all resources
  date: '2018-01-01'
```

Or we can pass it on the CLI, when running a `dbt` command:

```
$ dbt run --profiles-dir . --vars '{"date": "2018-01-01"}'
```

**Dictionaries** are data structures composed of key-value pairs.

```
{% set person = {
    ‘name’: ‘me’,
    ‘number’: 3
} %}

{{ person.name }}

me

{{ person[‘number’] }}

3
```

**Lists** are data structures that are ordered and indexed by integers.

```
{% set self = [‘me’, ‘myself’] %}

{{ self[0] }}

me
```

**If/else statements** are control statements that make it possible to provide instructions for a computer to make decisions based on clear criteria.

```
{% set temperature = 80% %}

On a day like this, I especially like

{% if temperature >70 %}

a refreshing mango sorbet.

{% else %}

A decadent chocolate ice cream.

{% endif %}

On a day like this, I especially like

a refreshing mango sorbet
```

**For loops** make it possible to repeat a code block while passing different values for each iteration through the loop.

```
{% set flavors = [‘chocolate’, ‘vanilla’, ‘strawberry’] %}

{% for flavor in flavors %}

Today I want {{ flavor }} ice cream!

{% endfor %}

Today I want chocolate ice cream!

Today I want vanilla ice cream!

Today I want strawberry ice cream!

```

**Macros** are a way of writing functions in Jinja. This allows us to write a set of statements once and then reference those statements throughout your code base.

```
{% macro hoyquiero(flavor, dessert = ‘ice cream’) %}

Today I want {{ flavor }} {{ dessert }}!

{% endmacro %}

{{ hoyquiero(flavor = ‘chocolate’) }}

Today I want chocolate ice cream!

{{ hoyquiero(mango, sorbet) }}

Today I want mango sorbet!
```

We can control for whitespace by adding a single dash on either side of the Jinja delimiter. This will trim the whitespace between the Jinja delimiter on that side of the expression.

### Macros
Write generic logic and reuse it on different models. Packages allow you to import macros other developers wtote, into your own project.
Macros a feature of Jinja, we can think them as functions

Macros should be created as a `.sql` file on the `macros` directory.

### Packages
Packages are a tool for importing models and macros into your dbt Project. These may have been written in by a coworker or someone else in the dbt community that you have never met. Fishtown Analytics maintains a site called [hub.getdbt.com](https://hub.getdbt.com/) for sharing open-source packages that you can install in your project. Packages can also be imported directly from GitHub, GitLab, or another site or from a subfolder in your dbt project.

**Installing Packages**
Packages are configured in the root of your dbt project in a file called `packages.yml`.
You can adjust the version to be compatible with your working version of dbt. Read the packages documentation to determine the version to use.
Packages are then installed executing the following command:
```
$ dbt deps --profiles-dir .
```

There are 3 different ways of installing packages:
- direct from the hub
- from github/gitlab (in this case use `revison` instaed of `version`, yoou can use both `HTTPS` or `SSH`)
- from a local directory

```
packages:
  - package: dbt-labs/dbt_utils
    version: 0.7.1
  - git: https://github.com/fishtown-analytics/dbt-utils.git
    revision: master
  - local: sub-folder
```

Packages can have models, macros, seeds and analysis

**Using Packages with Macros**
Once the package is installed, we can use the macros defined in it, for example, if we have installed `dbt-labs/dbt_utils` package, we can use the `date_spine` macro in the following way:
```
{{ dbt_utils.date_spine(
    datepart=”day”
    start_date=”to_date(‘01/01/2016’, ‘mm/dd/yyyy’)”,
    end_date=”dateadd(week, 1, current_date)”
    )
}}
```

## Advanced Materializations
Materializations are the way in which `dbt` writes the data in the database. There are different options:
- table
- view
- ephemeral (does not exists in teh database, they are created as CTE)
- [incremental](https://docs.getdbt.com/docs/building-a-dbt-project/building-models/configuring-incremental-models) (`dbt` only adds the new data, it does not creates the table from scratch all over again)
- [snapshots](https://docs.getdbt.com/docs/building-a-dbt-project/snapshots)

### Table Materialization
- Built as tables in the database
- Data is stored on disk
- Slower to build
- Faster to query
- Configure in dbt_project.yml or with the following config block
```
{{ config(materialized='table') }}
```


### View Materialization
- Built as views in the database
- Query is stored on disk
- Faster to build
- Slower to query
- Configure in dbt_project.yml or with the following config block
```
{{ config(materialized='view') }}
```

### Ephemeral Materialization
- Does not exist in the database
- Imported as CTE into downstream models
- Increases build time of downstream models
- Cannot query directly
- Configure in dbt_project.yml or with the following config block
```
{{ config(materialized='ephemeral') }}
```

#### Incremental Materialization
In case of selecting the `incremental` materialization, we should add some filter on the model:
```
{{ config(materialized='incremental')}}

with BLAH as (
    select * from {{ source('SOURCE', 'TABLE')}}
    {% if is_incremental() %}
    where timestamp_column >= (select max(timestamp_column) from {{ this }})
    {% endif %}
)

...

```

To define a model materialization as incremental, we first need the table to be created, if not the `{{ this }}` clause is going to fail.

If we add the `--full-refresh` command on `dbt run`, it is going to refresh the full table from scratch. Also, this is needed in case you add new columns on the model, since the previous version of teh table doe not have that new column.

You can include a `unique_key=ID_COLUMN` on the materialization column, to make an upsert. If not, there is a risk of inserting duplicates values.

#### Snapshot Materialization
In case you want to create a snapshot, you need to create a `.sql` file on the `snapshots` directory with the prper configuration.
There is a special command to execute the snapshots:
```
$ dbt snapshot --profiles-dir .
```

The snapshots tables preserve all the table changes. In case a record has changed from the source table, the snapshot table will hae 2 different recors for that same ID. 

Here is an example of a snapshot file:
```
{% snapshot mock_orders %}

{% set new_schema = target.schema + '_snapshot' %}

{{
    config(
      target_database='analytics',
      target_schema=new_schema,
      unique_key='order_id',

      strategy='timestamp',
      updated_at='updated_at',
    )
}}

select * from analytics.{{target.schema}}.mock_orders

{% endsnapshot %}
```

## Analyses
- Analyses are `.sql` files that live in the `analyses` directory.
- Analyses will not be run with `dbt run --profiles-dir .` like models. However, you can still compile these from Jinja-SQL to pure SQL using `dbt compile`. These will compile to the `target` directory.
- Analyses are useful for training queries, one-off queries, and audits

## Seeds
- Seeds are `.csv` files that live in the `seeds` folder.
- When executing `dbt seed --profiles-dir .`, seeds will be built in your Data Warehouse as tables. Seeds can be references using the ref macro - just like models!
- Seeds should be used for data that doesn't change frequently.
- Seeds should not be the process for uploading data that changes frequently
Seed are useful for loading country codes, employee emails, or employee account IDs

## Refactoring SQL for Modularity
A good practice to migrate and refactor legacy code, is to refactor the code alongside. This is to store the legacy code under `models/legacy` and run the model. At the same time we can store the same query at `models/marts` (or whatever we ant to be the productive path) and start changing this new query and run the model.

We can use a package called `dbt-labs/audit_helper` to compare both created tables(teh legacy one, and the refactored one). We should create a `.sql` file under the `analyses` directory, called `compare_queries.sql`
```
{% set old_etl_relation=ref('customer_orders') %} 

{% set dbt_relation=ref('fct_customer_orders') %}  {{ 

audit_helper.compare_relations(
        a_relation=old_etl_relation,
        b_relation=dbt_relation,
        primary_key="order_id"
    ) }}
```

And by executing `dbt compile --profiles-dir .`, we will generate the actual sql query on `target/compiled/PROJECT_NAME/analyses/compare_queries.sql`. We can take this query to an IDE connected to teh local database and execute it. As both queries on the models are the same one, we should see teh following output, meaning that all the records are the same:

| IN_A | IN_B | count | percent_of_total |
|------|------|-------|------------------|
| true | true | 99    | 100              |

Here is a summary on the steps to follow whenever we have to perform a migration

**Step 1: Migrate Legacy Code 1:1**
- Transfer your legacy code to your dbt project as is as a .sql file in the models folder
- Ensure that it can run and build in your data warehouse by running dbt run
- Depending on the systems you are migrating between, you may need to adjust the flavor of SQL in your existing code to successfully build the model.

**Step 2: Implement Sources / Translate Hard Coded Table References**
- For each of the raw tables referenced in the new model, configure a source to map to those tables
- Replace all the explicit table references in your query using the source macro.

**Step 3: Choosing a Refactoring Strategy**
Decide on your refactoring strategy
- Refactor on top of the existing model - create a new branch and refactor directly on the model that you created in the steps above.
- Refactor alongside the existing model - rename the existing model by prepending it with legacy. Then copy the code into a new file with the original file name. This one plays better with the auditing in step 6. 

**Step 4: CTE Groupings and Cosmetic Cleanups**
- Create one CTE for each source referenced at the top of your model
- Reimplement subqueries as CTEs beneath the source CTEs
- Update code to follow your style guide (at dbt Labs, we use all lowercase keywords, leverage whitespace for readability
- Resource: [dbt Labs, dbt style guide](https://github.com/dbt-labs/corp/blob/master/dbt_style_guide.md)

**Step 5: Centralizing Transformations & Splitting up Models**
Structure your SQL into layers of modeling via staging models, intermediate models and final models.
- Staging models:
    - Light transformations on source data should be captured in staging models
    - e.g. renaming columns, concatenating fields, converting data type
    - Update aliases with purposeful name¢RScan for redundant transformations in the code and migrate into staging models
    - Build dependencies between the existing model and the newly created staging models
- CTEs or intermediate models
    - Inspect the grain of the transformations in latest version of the model, look for opportunities to move filters and aggregations into earlier CTE
    - If the model code is lengthy or could be reusable in another case, break those CTEs into intermediate models
- Final models
    - For the remaining logic, look for opportunities to simplify aggregations and joins
    - It can also be helpful to update naming of CTEs for readability in the future.

**Step 6: Auditing**
- Audit your new model against your old query to ensure that none of the changes you implemented changed the results of the modeling.
- The goal is for both the original code and your final model to produce the same results
- The audit_helper package can be particularly helpful here ([audit_helper on hub.getdbt.com](https://github.com/dbt-labs/dbt-audit-helper))
