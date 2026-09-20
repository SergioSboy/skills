# Сетевой стек Linux

## TCP/IP

Модель OSI полезна как концептуальная модель, но Linux работает не с абстрактными «уровнями OSI»,
а с конкретными сетевыми протоколами и структурами ядра.

| Уровень     | Примеры             | Что важно для firewall                    |
| ----------- | ------------------- | ----------------------------------------- |
| Application | HTTP, DNS, SSH      | порт/протокол, иногда содержимое          |
| Transport   | TCP, UDP, ICMP      | source/destination port, connection state |
| Internet    | IPv4, IPv6          | source/destination IP, routing            |
| Link        | Ethernet, VLAN, ARP | interface, MAC, VLAN                      |


## Путь пакета через Linux

Пакет приходит на Linux через интерфейс, например eth0, дальше Linux определяет куда отправить этот пакет для
этого используется routing decision.

INPUT

Пакет предназначен самому Linux-хосту.

FORWARD

Пакет проходит через Linux, а не предназначен ему.

OUTPUT

Пакет создаётся самим Linux.

INPUT/FORWARD/OUTPUT определяются не тем, какой интерфейс используется, а направлением обработки пакета относительно самого Linux-хоста.

## Stateful filtering

Stateless firewall рассматривает каждый пакет независимо.
Stateful firewall дополнительно учитывает состояние соединения.

## Conntrack

Она хранит состояние потоков/соединений.

Firewall получает возможность использовать состояния:

```
NEW
ESTABLISHED
RELATED
INVALID
```

NEW

Пакет относится к соединению, которое firewall ещё не видел как установленное.

ESTABLISHED

Соединение уже существует.

RELATED

Есть новое соединение, связанное с уже существующим соединением.

INVALID

Пакет не удаётся корректно сопоставить с ожидаемым состоянием conntrack.


## Почему асимметричная маршрутизация важна

Если stateful firewall находится только на Router A, он может увидеть:

SYN

но не увидеть ответ:

SYN/ACK

В результате conntrack и firewall state могут не соответствовать реальному состоянию соединения.


## Таблицы, цепочки, правила и policy

Теперь можно перейти к концепции firewall configuration.

Rule

Конкретное условие и действие:

```
if source = 10.10.10.0/24
and destination port = 443
then ACCEPT
```

Chain

Набор правил, обрабатываемых последовательно.

```
INPUT
 ├── allow loopback
 ├── allow established
 ├── allow SSH
 ├── allow HTTPS
 └── drop
```

Table

Логическая область/набор правил для определённого типа обработки.

В iptables таблицы исторически группируют функциональность:

```
filter
nat
mangle
...
```

В nftables модель несколько другая, и к ней мы подробно придём в пункте 3.


### Default policy

Что делать, если ни одно правило явно не сработало.

Концептуально:

```
default ACCEPT
```

```
default DROP
```

Для production firewall это фундаментальный architectural decision.


## Почему порядок правил критичен

```
1. DROP all
2. ACCEPT TCP/443
```

Поэтому firewall configuration нужно читать не как набор независимых строк,
а как программу, которая обрабатывает поток пакетов.


Firewall ruleset — это маленькая программа принятия решений над сетевыми пакетами.

Если система использует модель first match, правило №2 никогда не будет достигнуто.


## Практический production-like пример

```
Internet → Web:443       allowed
Web → API:8080           allowed
API → DB:5432            allowed
Internet → DB:5432       denied
Internet → API:8080      denied
```

Где физически/логически находится firewall и какие из этих потоков проходят через INPUT, а какие через FORWARD?

Здесь архитектор сначала должен построить traffic matrix, а не сразу писать firewall rules.

Один и тот же порт 443 может использовать совершенно разные firewall paths в зависимости от архитектуры.


# iptables

## Основная идея

iptables — это интерфейс управления Linux firewall на базе netfilter.

Важно разделять:

- netfilter — инфраструктура firewall hooks внутри Linux kernel;
- iptables — исторический userspace-инструмент для управления правилами netfilter;
- conntrack — механизм отслеживания connection state;
- NAT — отдельная функциональность netfilter, управляемая соответствующими правилами.

То есть iptables — не сам firewall kernel.

## Модель iptables

В классической модели iptables есть:

```
Table
  │
  └── Chain
        │
        ├── Rule
        ├── Rule
        ├── Rule
        └── ...
```

Например

```
filter
 ├── INPUT
 │    ├── allow loopback
 │    ├── allow ESTABLISHED
 │    ├── allow SSH
 │    └── DROP
 │
 ├── OUTPUT
 │    └── ...
 │
 └── FORWARD
      ├── allow established
      ├── allow HTTPS
      └── DROP
```

Table

Определяет функциональную область.

Chain

Определяет точку/контекст обработки.

Rule

Определяет конкретное условие и действие.

## Основные таблицы

| Table    | Назначение                                             |
| -------- | ------------------------------------------------------ |
| `filter` | фильтрация                                             |
| `nat`    | Network Address Translation                            |
| `mangle` | изменение/маркировка пакетов                           |
| `raw`    | специальные операции, в частности влияние на conntrack |

### filter

Главная таблица для обычного firewall policy.

Здесь находятся:

```
INPUT
OUTPUT
FORWARD
```

### nat

Используется для NAT.

Например:

```
SNAT
DNAT
MASQUERADE
```

Типичные chains:

```
PREROUTING
POSTROUTING
OUTPUT
```

NAT не является обычной packet-filtering policy.

Его задача — изменить addressing/translation behavior, а не решить основной вопрос security policy.

### mangle

Исторически используется для специальных изменений и маркировки пакетов.

Для обычного enterprise firewall чаще всего не стоит начинать архитектуру с mangle.


### raw

raw существует для случаев, когда требуется воздействовать на обработку до обычного conntrack path.


## Основные chains

В классическом iptables наиболее важны:

```
INPUT
OUTPUT
FORWARD
```

А для NAT также:

```
PREROUTING
POSTROUTING
```

## Почему PREROUTING и POSTROUTING важны

До routing decision существует PREROUTING.

После того как Linux решил, что пакет будет отправлен через eth1, существует POSTROUTING.

Это особенно важно для NAT.

## Чтение существующего ruleset

```
iptables-save
```

выдаёт ruleset в формате, удобном для сохранения и восстановления.

Пример:

```
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]

-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p tcp --dport 22 -s 10.10.10.0/24 -j ACCEPT

-A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
-A FORWARD -p tcp --dport 443 -j ACCEPT

COMMIT
```



## Правило iptables

Рассмотрим:

```
iptables -A INPUT \
  -p tcp \
  -s 10.10.10.0/24 \
  --dport 22 \
  -j ACCEPT
```

-A INPUT

Добавить правило в INPUT.

-p tcp

Только TCP.

-s 10.10.10.0/24

Source network.

--dport 22

Destination port 22.

-j ACCEPT

Action:

ACCEPT

## Порядок правил

Правила в chain обрабатываются последовательно.

```
1. -A INPUT -p tcp --dport 22 -j DROP
2. -A INPUT -p tcp --dport 22 -s 10.10.10.0/24 -j ACCEPT
```

SSH из 10.10.10.0/24 всё равно будет заблокирован.

Почему?

Пакет сначала совпал:

rule #1

и получил:

DROP

до того, как дошёл до rule #2.

## Terminating и non-terminating actions

Не каждое правило обязательно заканчивает обработку chain.

```
ACCEPT
DROP
REJECT
```

обычно завершают текущую обработку.

## Counters

iptables хранит packet/byte counters.

Это уже observability.

## Stateful rule

```
iptables -A INPUT \
  -m conntrack \
  --ctstate ESTABLISHED,RELATED \
  -j ACCEPT
```

## INPUT пример

```
INPUT policy = DROP

1. loopback             → ACCEPT
2. ESTABLISHED,RELATED  → ACCEPT
3. management → TCP/22  → ACCEPT
4. any → TCP/443        → ACCEPT
5. everything else      → DROP
```


```
iptables -P INPUT DROP

iptables -A INPUT -i lo -j ACCEPT

iptables -A INPUT \
  -m conntrack \
  --ctstate ESTABLISHED,RELATED \
  -j ACCEPT

iptables -A INPUT \
  -p tcp \
  -s 10.10.10.0/24 \
  --dport 22 \
  -j ACCEPT

iptables -A INPUT \
  -p tcp \
  --dport 443 \
  -j ACCEPT
```

## FORWARD пример

```
Client network
10.10.10.0/24
       │
       ▼
 Linux firewall
       │
       ▼
Server network
10.20.20.0/24
```


```
iptables -P FORWARD DROP

iptables -A FORWARD \
  -m conntrack \
  --ctstate ESTABLISHED,RELATED \
  -j ACCEPT

iptables -A FORWARD \
  -s 10.10.10.0/24 \
  -d 10.20.20.0/24 \
  -p tcp \
  --dport 443 \
  -j ACCEPT
```

## Почему iptables -L недостаточно

полезнее

```
iptables-save
```

iptables-save позволяет получить ruleset в форме, близкой к declarative configuration


# nftables

## Основная идея

nftables — современный framework для настройки packet filtering, NAT и связанных с этим механизмов Linux.

```
iptables:
tables → chains → rules
```

но разные таблицы имеют исторически разные semantics.

В nftables модель более унифицированная:

```
family
  │
  └── table
        │
        ├── chain
        │     ├── rule
        │     ├── rule
        │     └── ...
        │
        ├── set
        ├── map
        └── ...
```


## Family

Первый уровень — family.

```
ip
ip6
inet
arp
bridge
netdev
```

## Table

Создадим таблицу:

```
nft add table inet firewall
```

```
inet
└── firewall
```

Table — это логический контейнер для:

- chains;
- sets;
- maps;
- counters;
- других объектов.

В nftables таблица — прежде всего логический namespace/контейнер объектов.

## Chain

Chain содержит правила.

Например:
```
nft add chain inet firewall input
```

```
inet firewall
└── input
```

Но здесь появляется очень важное отличие от обычной пользовательской chain в iptables.

Regular chain

Обычная цепочка, в которую можно переходить из других chains.

Base chain

Chain, непосредственно привязанная к kernel hook.

## Base chain

```
nft add chain inet firewall input \
  '{ type filter hook input priority 0; policy drop; }'
```

```
type   = filter
hook   = input
priority = 0
policy = drop
```

```
Kernel
  │
  ▼
INPUT hook
  │
  ▼
inet firewall/input
  │
  ├── rule
  ├── rule
  └── rule
```

В nftables можно создавать свои base chains и явно определять:

hook;
priority;
policy.

Это даёт значительно больше контроля.

## Hooks

Основные hooks, которые нужно знать:

```
prerouting
input
forward
output
postrouting
```


Они соответствуют различным этапам packet processing.

```
                  packet
                    │
                    ▼
               prerouting
                    │
                    ▼
                 routing
               /         \
              /           \
             ▼             ▼
          input         forward
             │             │
             │             ▼
             │          postrouting
             │             │
             ▼             ▼
          local          egress
```


## Priority

```
hook input priority -100
hook input priority 0
hook input priority 100
```

```
INPUT hook

priority -100
     ↓
chain A

priority 0
     ↓
chain B

priority 100
     ↓
chain C
```

Они будут выполняться в определённом порядке.


## Создание базового firewall

```
nft add table inet firewall
```

Создаём input chain:

```
nft add chain inet firewall input \
  '{ type filter hook input priority 0; policy drop; }'
```

Создаём output:

```
nft add chain inet firewall output \
  '{ type filter hook output priority 0; policy accept; }'
```

И forward:

```
nft add chain inet firewall forward \
  '{ type filter hook forward priority 0; policy drop; }'
```

## Sets

Принадлежит ли значение множеству?

```
nft add set inet firewall ssh_sources \
    '{ type ipv4_addr; }'
```

```
nft add element inet firewall ssh_sources \
    '{ 10.10.10.0/24, 10.20.10.0/24, 192.0.2.10, 192.0.2.11 }'
```

## Maps

Какому значению соответствует этот ключ?

Maps позволяют выразить более сложную policy logic без большого количества дублирующих rules.

## Counters

```
nft add counter inet firewall https_counter
```




# Список литературы

https://www.youtube.com/watch?v=SYM5MvV4VIk - Настройка firewall iptables на linux это не сложно. Linux Tutorial.
https://www.youtube.com/watch?v=L1JtmAiSaFQ - устройство NAT
https://www.youtube.com/watch?v=a55ecIWIkVc - ВСE ЧТО НАДО ЗНАТЬ ПРО СЕТИ
https://www.youtube.com/watch?v=a55ecIWIkVc - ВСE ЧТО НАДО ЗНАТЬ ПРО СЕТИ Часть 2