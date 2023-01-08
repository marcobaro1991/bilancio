# Bilancio Api


## Run the webserver that expose graphql api through the docker container:
```
docker-compose down && docker-compose run --service-ports api bash
mix local.hex --force
mix deps.get
mix local.rebar --force
mix ecto.reset
mix test
mix s

```
The application can generate the schema exposed by:
```
mix sdl
```

## RUN the container in prod
```
docker-compose up -d
```


## Verify containers logs
```
docker-compose logs -f
```

## Graphql curl example:
-  login:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Authorization: Bearer ' \
  --header 'Content-Type: application/json' \
  --data '{"query":"mutation ($email: String!, $password: String!) {\n\tlogin(email: $email, password: $password) {\n\t\t__typename\n\t\t... on LoginSuccess {\n\t\t\ttoken\n\t\t\tidentifier\n\t\t}\n\n\t\t... on LoginFailure {\n\t\t\terror\n\t\t}\n\t}\n}\n","variables":{"email":"baroni.marco.91@gmail.com","password":"diocane"}}'
```

-  logout:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzM3OTE2NjQsImlhdCI6MTY3MzE4Njg2NCwianRpIjoiYjNkYTg3ZGQtMTVmZi00ZjQwLWI3MjEtMTY0MTVmYWRlM2MyIiwic3ViIjoiOGU1NjcxMDUtN2RjMy00MTMxLWIwMWQtZWJiZTU1ZjhlMjZjIiwiaXNzIjoiYXV0aF9zZXJ2aWNlIn0.8eiWfWkqrc7YPXX0sg1Tblte65Km-ptdQWDNtj09BoM' \
  --header 'Content-Type: application/json' \
  --data '{"query":"mutation {\n\tlogout {\n\t\t__typename\n\t\t... on LogoutSuccess {\n\t\t\tmessage\n\t\t}\n\n\t\t... on LogoutFailure {\n\t\t\terror\n\t\t}\n\t}\n}\n"}'
```

-  get user:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzM3OTE3ODgsImlhdCI6MTY3MzE4Njk4OCwianRpIjoiNDEwNGM4ZTQtNGIwMi00MDhmLWFlMmYtMzU1YjIyN2I3YzhhIiwic3ViIjoiOTE1MTMyYWEtYTgyOC00NDdjLTgxNDYtNDcxZjk4NjY5NGE1IiwiaXNzIjoiYXV0aF9zZXJ2aWNlIn0.NksSPfL5ea07pbNpZQpALABrvT-1y8Bo6fRBFYY_QZw' \
  --header 'Content-Type: application/json' \
  --data '{"query":"query ($orderBy: MovementsOrder) {\n\tme {\n\t\tfirstName\n\t\tlastName\n\t\tinsertedAt\n\t\tstatus\n\t\temail\n\t\tmovements(order: $orderBy) {\n\t\t\tidentifier\n\t\t\ttitle\n\t\t\tdescription\n\t\t\tvalue\n\t\t\toccurredAt\n\t\t}\n\t}\n}\n","variables":{"orderBy":{"by":"OCCURRED_AT","type":"ASC"}}}'
```

-  get movement:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzM3OTE3ODgsImlhdCI6MTY3MzE4Njk4OCwianRpIjoiNDEwNGM4ZTQtNGIwMi00MDhmLWFlMmYtMzU1YjIyN2I3YzhhIiwic3ViIjoiOTE1MTMyYWEtYTgyOC00NDdjLTgxNDYtNDcxZjk4NjY5NGE1IiwiaXNzIjoiYXV0aF9zZXJ2aWNlIn0.NksSPfL5ea07pbNpZQpALABrvT-1y8Bo6fRBFYY_QZw' \
  --header 'Content-Type: application/json' \
  --data '{"query":"query ($identifier: Uuid!) {\n\tmovement(identifier: $identifier) {\n\t\ttitle\n\t\tdescription\n\t\tidentifier\n\t\toccurredAt\n\t\tvalue\n\t}\n}\n","variables":{"identifier":"fbf2ebb9-a8ec-42d2-a36f-47184b155fcc"}}'
```

-  delete account:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzM3OTE3MDEsImlhdCI6MTY3MzE4NjkwMSwianRpIjoiNGMyOWRhY2QtNjc2OC00MmVmLTg1ZTMtM2M0ZmFiN2Q2NjU3Iiwic3ViIjoiOGU1NjcxMDUtN2RjMy00MTMxLWIwMWQtZWJiZTU1ZjhlMjZjIiwiaXNzIjoiYXV0aF9zZXJ2aWNlIn0.vslMPP8voWw7Kp9TZRx05q7aJhFAzQmQJKWu1syRuzQ' \
  --header 'Content-Type: application/json' \
  --data '{"query":"mutation {\n\tdeactivateUser {\n\t\t__typename\n\t\t... on DeactivateUserSuccess {\n\t\t\tmessage\n\t\t}\n\n\t\t... on DeactivateUserFailure {\n\t\t\terror\n\t\t}\n\t}\n}\n"}'
```

-  create movement:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzM3OTE3ODgsImlhdCI6MTY3MzE4Njk4OCwianRpIjoiNDEwNGM4ZTQtNGIwMi00MDhmLWFlMmYtMzU1YjIyN2I3YzhhIiwic3ViIjoiOTE1MTMyYWEtYTgyOC00NDdjLTgxNDYtNDcxZjk4NjY5NGE1IiwiaXNzIjoiYXV0aF9zZXJ2aWNlIn0.NksSPfL5ea07pbNpZQpALABrvT-1y8Bo6fRBFYY_QZw' \
  --header 'Content-Type: application/json' \
  --data '{"query":"mutation ($movement: InputMovement!) {\n\tcreateMovement(movement: $movement) {\n\t\t__typename\n\t\t... on Movement {\n\t\t\ttitle\n\t\t\tdescription\n\t\t\tvalue\n\t\t\toccurredAt\n\t\t\tidentifier\n\t\t}\n\t\t... on MovementNotCreated {\n\t\t\terror\n\t\t}\n\t}\n}\n","variables":{"movement":{"title":"illiad","description":"pagamento mensile","value":12.32,"occurredAt":"2022-07-23"}}}'
```

-  delete movement:
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzM3OTE3ODgsImlhdCI6MTY3MzE4Njk4OCwianRpIjoiNDEwNGM4ZTQtNGIwMi00MDhmLWFlMmYtMzU1YjIyN2I3YzhhIiwic3ViIjoiOTE1MTMyYWEtYTgyOC00NDdjLTgxNDYtNDcxZjk4NjY5NGE1IiwiaXNzIjoiYXV0aF9zZXJ2aWNlIn0.NksSPfL5ea07pbNpZQpALABrvT-1y8Bo6fRBFYY_QZw' \
  --header 'Content-Type: application/json' \
  --data '{"query":"mutation ($movement_identifier: Uuid!) {\n\tdeleteMovement(identifier: $movement_identifier) {\n\t\t__typename\n\t\t... on DeleteMovementFailure {\n\t\t\terror\n\t\t}\n\t\t... on DeleteMovementSuccess {\n\t\t\tmessage\n\t\t}\n\t}\n}\n","variables":{"movement_identifier":"f5eee0f3-ab22-4b62-8cc1-6ab58de78d60"}}'
```

-  get categories (globally):
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Authorization: Bearer ' \
  --header 'Content-Type: application/json' \
  --data '{"query":"query {\n\tcategories {\n\t\ttitle\n\t\tcolor\n\t\tidentifier\n\t}\n}\n"}'
```

-  create category (just for the logged in user):
```
curl --request POST \
  --url http://127.0.0.1:4000/graphql \
  --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NzM3OTE3ODgsImlhdCI6MTY3MzE4Njk4OCwianRpIjoiNDEwNGM4ZTQtNGIwMi00MDhmLWFlMmYtMzU1YjIyN2I3YzhhIiwic3ViIjoiOTE1MTMyYWEtYTgyOC00NDdjLTgxNDYtNDcxZjk4NjY5NGE1IiwiaXNzIjoiYXV0aF9zZXJ2aWNlIn0.NksSPfL5ea07pbNpZQpALABrvT-1y8Bo6fRBFYY_QZw' \
  --header 'Content-Type: application/json' \
  --data '{"query":"mutation ($category: InputCategory!) {\n\tcreateCategory(category: $category) {\n\t\t__typename\n\t\t... on Category {\n\t\t\ttitle\n\t\t\tcolor\n\t\t\tidentifier\n\t\t}\n\t\t... on CategoryNotCreated {\n\t\t\terror\n\t\t}\n\t}\n}\n","variables":{"category":{"title":"Mutuo"}}}'
```