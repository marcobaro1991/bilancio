# Bilancio Api


## API - RUN the container in developer mode
```
docker-compose run --service-ports api bash
mix deps.get
mix ecto.reset
mix s
```


## RUN the container in prod
```
docker-compose up -d
```


## Verify containers logs
```
docker-compose logs -f
```

Ricorda:
il mix s sta in ascolto dei vari cambiamenti del codice e ricompila in automatico.


## TODO
- fixare dialyzerignore (specifica funzione e non numero riga)
- filtri su movements
- movements category
- pensare al concetto di movimento ricorrente (annuale, mensile)
- mutation registrazione
- mutation di update movimento