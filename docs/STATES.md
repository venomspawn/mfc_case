# Статусная модель заявки на неавтоматизированную услугу

Модель заявки на неавтоматизированную услугу поддерживает следующие статусы.

*  `packaging` (формирование пакета документов);
*  `pending` (ожидание отправки в ведомство);
*  `processing` (обработка заявки в ведомстве);
*  `issuance` (выдача результата заявки);
*  `rejecting` (возврат результата заявки в ведомство);
*  `closed` (заявка закрыта).

Статус заявки `packaging` является изначальным и устанавливается обработчиком
`on_case_creation` непосредственно после создания записи заявки.

# Жизненный цикл заявки на неавтоматизированную услугу

Жизненный цикл заявки можно описать следующим графом переходов, где вершины
графа — это названия статуса, приведённые выше, или его отсутствие (сразу
после создания записи заявки), а метки дуг — это вызовы функций модуля с учётом
условий на атрибуты.

```
            +-+   A   +-----------+
            | |------>| packaging |
            +-+       +-----------+
                         ^     |
                      B2 |     | B1
                         |     V
                       +---------+
    +------------------| pending |------------+
    |       +--------->|         |            |
    |       |          +---------+            |
    |       |               |                 |
    |       |               | B3              |
    |       |               V                 |
    |       |        +------------+           |
    | B4    | B5     | processing |           | B6
    |       |        +------------+           |
    |       |               |                 |
    |       |               | B7              |
    v       |               V                 V
  +-----------+   B8  +----------+  B9   +--------+
  | rejecting |<------| issuance |------>| closed |
  +-----------+       +----------+       +--------+
```

Метки дуг обозначают следующее:

*   `A` — вызов функции `on_case_creation` для записи заявки;
*   `B1` — вызов функции `change_status_to` для записи заявки и строки
    `pending`;
*   `B2` — вызов функции `change_status_to` для записи заявки и строки
    `packaging` при условии, что атрибут `added_to_rejecting_at` заявки
    отсутствует или его значение пусто;
*   `B3` — вызов функции `change_status_to` для записи заявки и строки
    `processing` при одновременном выполнении следующих условий:
    -   атрибут `issue_location_type` отсутствует или его значение не равно
        `institution`;
    -   атрибут `added_to_rejecting_at` отсутствует или его значение пусто;
*   `B4` — вызов функции `change_status_to` для записи заявки и строки
    `rejecting` при условии, что атрибут `added_to_rejecting_at` заявки
    присутствует и его значение непусто;
*   `B5` — вызов функции `change_status_to` для записи заявки и строки
    `pending`;
*   `B6` — вызов функции `change_status_to` для записи заявки и строки
    `processing`, если выполняется хотя бы одно из следующих условий:
    -   атрибут `issue_location_type` присутствует и его значение равно
        `institution`;
    -   атрибут `added_to_rejecting_at` присутствует и его значение непусто;
*   `B7` — вызов функции `change_status_to` для записи заявки и строки
    `issuance`;
*   `B8` — вызов функции `change_status_to` для записи заявки и строки
    `rejecting` при условии, что атрибут `rejecting_expected_at` присутствует,
    его значение начинается с даты, записанной в формате ISO 8601, и эта дата
    строго меньше текущей даты;
*   `B9` — вызов функции `change_status_to` для записи заявки и строки `closed`
    при условии, что атрибут `rejecting_expected_at` присутствует, его значение
    начинается с даты, записанной в формате ISO 8601, и эта дата больше текущей
    даты или равна ей.
