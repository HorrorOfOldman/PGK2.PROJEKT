extends Node

var current_health = 35
var current_mana = 30
var max_health = 35
var max_mana = 30
var damage = 20
#zaklęcia
#im więcej zaklęć, to trzeba dodać nowe puste elemanty do tablicy
var spell = ["","",""]		#nazwa
var spell_dmg = [0,0,0]		#obrażenia
var spell_cost = [0,0,0,]	#koszta
var spell_effect = [0,0,0]
#przedmioty
var item = []			#nazwa
var item_amount = []	#ilość
var item_effect = []	#efekt

#inicjalizacja zaklęć
func spell_init():
	# spell 1
	spell[0] = "Fireball"
	spell_dmg[0] = 30
	spell_cost[0] = 10
	spell_effect[0] = 1#podpalenie - -5punktów hp przeciwnika w następnej turze
	# spell 2
	spell[1] = "One jar"
	spell_dmg[1] = 10
	spell_cost[1] = 4
	spell_effect[1] = 0
	# spell 3
	spell[2] = "Coś Potężnego"
	spell_dmg[2] = 50
	spell_cost[2] = 30
	spell_effect[2] = 0#brak efektów dodatkowych

#inicjalizacja przedmiotów
func item_init():
	#item 1
	item.append("Chleb")
	item_amount.append(3)
	item_effect.append(0)
	#item 2
	item.append("Wino")
	item_amount.append(3)
	item_effect.append(1)
	#item 3
	item.append("Drugie śniadanie")
	item_amount.append(3)
	item_effect.append(2)
