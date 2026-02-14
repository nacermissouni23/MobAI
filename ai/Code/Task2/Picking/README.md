## gridItem.json:
contains the emplacement of floor 1-2-3-4 and asssidgned product

## grid0.json:
contains the emplacement of ground floor and racks

## grok.py : 
search for product in which floor and which slot and suggest the shortest path for current position -> product -> elevator
check for congestion and avoid it by suggesting another route / floor or waiting ( it depedns the case)

## racks.py : 
choose positsion for each product in ground floor based on weight , frequent delivery and other metrics

## expidetion.py :
decide order and route from racks to expedition zone

## workflow.py :
execute the three scripts for full workflow 