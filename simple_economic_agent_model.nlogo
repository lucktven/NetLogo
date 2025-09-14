globals [
  banks  ;; глобальна змінна, що визначає кількість банків
  people  ;; глобальна змінна, що визначає кількість осіб
]

turtles-own [
  savings  ;; власна змінна черепашок, що відображає заощадження
  loans  ;; власна змінна черепашок, що відображає позики
  wallet  ;; власна змінна черепашок, що відображає гаманець
  wealth  ;; власна змінна черепашок, що відображає стан багатства
]

breed [people person]  ;; визначення нового виду "людина" з основною формою "person"
breed [banks bank]  ;; визначення нового виду "банк" з основною формою "bank"

to setup  ;; процедура налаштування
  clear-all  ;; очищення всіх агентів (черепашок та патчів)
  create-people 100 [  ;; створення 100 черепашок виду "людина"
    setxy random-xcor random-ycor  ;; випадкове розміщення на полі
    set color blue  ;; встановлення кольору "синій"
    set wallet (random rich-threshold) + 1  ;; генерація випадкового гаманця
    set savings 0  ;; ініціалізація заощаджень
    set loans 0  ;; ініціалізація позик
    set wealth 0  ;; ініціалізація багатства
  ]
  
  create-banks 3 [  ;; створення 3 банків
    setxy random-xcor random-ycor  ;; випадкове розміщення на полі
    set color yellow  ;; встановлення кольору "жовтий"
  ]
  
  reset-ticks  ;; скидання лічильника кроків
end

to go  ;; процедура кроку
  ask people [
    do-business
    balance-books
    get-shape
  ]
  tick
end

to do-business  ;; процедура здійснення бізнес-операцій
  rt random-float 360  ;; поворот на випадковий кут
  fd 1  ;; рух на одну одиницю вперед
  
  let customer one-of other people-here  ;; вибір випадкового клієнта серед інших осіб на цьому ж патчі
  if customer != nobody [  ;; якщо знайдено клієнта
    if random 2 = 0 [  ;; з ймовірністю 50%
      if random 2 = 0 [  ;; з ймовірністю 50%
        exchange-money customer 5  ;; обмінувати гроші з клієнтом (5 одиниць)
      ] else [
        exchange-money customer 2  ;; обмінувати гроші з клієнтом (2 одиниці)
      ]
    ]
  ]
end

to exchange-money [receiver amount]  ;; процедура обміну грошей
  if wallet >= amount [  ;; якщо в гаманці достатньо коштів
    set wallet (wallet - amount)  ;; зменшити гаманець
    set receiver.wallet (receiver.wallet + amount)  ;; збільшити гаманець отримувача
  ]
end

to balance-books  ;; процедура балансування бухгалтерії
  if wallet < 0 [  ;; якщо гаманець має від'ємний баланс
    if savings >= abs(wallet) [  ;; якщо заощаджень достатньо для покриття витрат
      withdraw-from-savings abs(wallet)  ;; зняти кошти з заощаджень
    ] else [
      take-out-loan abs(wallet)  ;; взяти позику на покриття витрат
    ]
  ] else [
    deposit-to-savings wallet  ;; покласти кошти в заощадження
  ]  
  if loans > 0 and savings > 0 [  ;; якщо є позики та кошти в заощадженнях
  if savings >= loans [  ;; якщо заощаджень достатньо для погашення позик
    withdraw-from-savings loans  ;; зняти кошти з заощаджень для погашення позик
    repay-a-loan loans  ;; погасити позики
  ] else [
    withdraw-from-savings savings  ;; зняти доступні кошти з заощаджень
    repay-a-loan wallet  ;; погасити позики з коштів гаманця
  ]
]

to deposit-to-savings [amount]  ;; процедура внесення коштів на заощадження
  set wallet (wallet - amount)  ;; зменшити гаманець
  set savings (savings + amount)  ;; збільшити заощадження
end

to withdraw-from-savings [amount]  ;; процедура зняття коштів з заощаджень
  set wallet (wallet + amount)  ;; збільшити гаманець
  set savings (savings - amount)  ;; зменшити заощадження
end

to repay-a-loan [amount]  ;; процедура погашення позики
  set loans (loans - amount)  ;; зменшити позики
  set wallet (wallet - amount)  ;; зменшити гаманець
end

to take-out-loan [amount]  ;; процедура отримання позики
  set loans (loans + amount)  ;; збільшити позики
  set wallet (wallet + amount)  ;; збільшити гаманець
end

to get-shape  ;; процедура оновлення форми (кольору) в залежності від стану багатства
  if savings > 10 [  ;; якщо заощаджень більше 10
    set color green  ;; встановити кольору "зелений"
  ]
  if loans > 10 [  ;; якщо позик більше 10
    set color red  ;; встановити кольору "червоний"
  ]
  set wealth (savings - loans)  ;; обчислити стан багатства
end
