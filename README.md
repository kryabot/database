# Databases
### MySQL
Core database used for most things.

In my case size of database size was very limited, because server plan is cheap one and database is managed by provider. 

Max size: 2GB

Changes to database deployed manually directly via sql command.

### PostgreSQL
Secondary database with more space, runs on Oracle cloud free tier, managed on own. 

Max size: ~20GB (free tier instance)
After syncing Twitch messages, database took ~7GBs

Changes to database deployed manually via Liquibase. Idea is to move it into CICD process.