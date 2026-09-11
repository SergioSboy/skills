# Keepalived

## Назначение keepalived
`keepalived` - обеспечивает высокую достпунть за счет механизмов VRRP.

Основные задачи:
- обеспечивает непрерывную доступность сервиса для клиентов;
- назначает VIP группе серверов;
- опеределяет MASTER и BACKUP;
- автоматический переключает VIP на BACKUP при отказе MASTER;

## Протокол VRRP (Virtual Router Redundancy Protocol)
`VRRP` - сетевой протокол для обеспечения отказоустойчивости шлюза/виртуального IP.

Основная идея:
- несколько серверов объединяются в VRRP-группу;
- один сервер становиться MASTER, остальные - BACKUP;
- используетсвя общий VIP;

VRRP обеспечивает отказоустойчивость VIP: выбирает MASTER,
остальные работают как BACKUP,
а при отказе MASTER один из BACKUP автоматически забирает VIP.

## Роли MASTER, BACKUP, приоритеты
- `MASTER` - активный сервер, который в данный момент владеет VIP и обрабатывает трафик;
- `BACKUP` - резервный сервер, который следит за MASTER и готовый принять VIP при его отказе;
- `Priority` - приоритет сервера в VRRP. Чем выше значение, тем выше вероятность стать MASTER.

Важно: state: MASTER - это начальное состояние. Фактическая роль определяется VRRP с учетом 
приоритета и состояния узлов.

## Advert interval и preemption
* `advert interval` - интервал, с которым MASTER отправляет VRRP Advertisement сообщения, сообщая
BACKUP, что он работает. (advert_int - как часто MASTER сообщает, что он жив)

* `preemption` - механизм, при котором сервер с более высоким приоритетом может забрать роль MASTER
обратно, когда он восстановиться. То есть preemption позволяет серверу с более высоким priority
вернуть себе роль MASTER. (preemption - может ли сервер с более высоким priority вернуть роль MASTER после восстановления)
P.s по умолчанию preemption, но можно добавить nopreempt чтобы VIP не забирал обратно MASTER

## Назначение vrrp_instance, virtual_router_id, unicast и health-check
`vrrp_instance` - определяет VRRP-группу и ее параметры.

```conf
vrrp_instance VI_1 {
    ...
}
```
- VI_1 - имя VRRP-инстанса;
- Внутри задаются state, priority, VIP, advert_int и другие параметры;
- MASTER и BACKUP должны иметь одинаковый vrrp_instance.

`virtual_router_id` - идентификатор VRRP-группы, позволяет серверам понять к какой VRRP-группе они относятся;
```conf
virtual_router_id: 51
```

`unicast` - передача VRRP-сообщения напрямую между укзанными IP-адресами вместо multicast.
Это полезно, если сеть или провайдер не поддерживает multicast.

`health-check` - проверяет состояние сервиса, например Nginx.
```conf
vrrp_script check_nginx {
    script "/usr/bin/curl -fs http://127.0.0.1/health"
    interval 2
    weight -20
}
```
если `/health` отвечает успешно, то MASTER работает

## Причины split-brain и способы его предотвращения
`split-brain` - ситуация, когда оба сервера считают себя MASTER и одновременно
пытаются владеть одним VIP.

Основыне причины:

- Потеря связи между MASTER и BACKUP;
- Неправильный unicast_peer - узлы не могут обмениваться сообщениями;
- Firewall блокирует VRRP-трафик;
- Ошибки конфигурации - одинаковые/неправильные праметры VRRP;

Как предотвратить:
- Обеспечивать стабильный VRRP;
- Использовать разные priority;
- Использовать preempt осознанно;
- Использовать health-check;
- Мониторить состояние VRRP и VIP;

## Команды для запуска плейбуков
### Playbook LoadBalancer
```bash
ansible-playbook -i inventory.yml balancer.yml
```

### Playbook Nginx
```bash
ansible-playbook -i inventory.yml nginx.yml
```

### Playbook Keepalived
```bash
ansible-playbook -i inventory.yml keepalived.yml
```

## Команды для проверки работы

### Проверка VIP на lba
```bash
sudo systemctl status keepalived
ip addr show enp0s1
```

### Иммитируем падения MASTER
```bash
sudo systemctl stop keepalived
```

### Восстанваливаем MASTER
```bash
sudo systemctl start keepalived
```
