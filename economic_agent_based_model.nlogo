
globals [
  bank-loans
  bank-reserves
  bank-deposits
  bank-to-loan
  x-max
  y-max
  rich
  poor
  middle-class
  rich-threshold
]
turtles-own [
  savings
  loans
  wallet
  temp-loan
  wealth
  customer
]
to setup
  clear-all
  initialize-variables
  ask patches [set pcolor black]
  set-default-shape turtles "person"
  create-turtles people [setup-turtles]
  setup-bank
  set x-max 300
  set y-max 2 * money-total
  reset-ticks
end
to setup-turtles  ;; turtle procedure
  set color blue
  setxy random-xcor random-ycor
  set wallet (random rich-threshold) + 1 ;;limit money to threshold
  set savings 0
  set loans 0
  set wealth 0
  set customer -1
end
to setup-bank ;;initialize bank
  set bank-loans 0
  set bank-reserves 0
  set bank-deposits 0
  set bank-to-loan 0
end
to initialize-variables
  set rich 0
  set middle-class 0
  set poor 0
  set rich-threshold 10
end
to get-shape  ;;turtle procedure
  if (savings > 10)  [set color green]
  if (loans > 10) [set color red]
  set wealth (savings - loans)
end
to go
  ;;tabulates each distinct class population
  set rich (count turtles with [savings > rich-threshold])
  set poor (count turtles with [loans > 10])
  set middle-class (count turtles - (rich + poor))
  ask turtles [
    ifelse ticks mod 3 = 0
      [do-business] ;;first cycle, "do business"
      [ifelse ticks mod 3 = 1  ;;second cycle, "balance books" and "get shape"
         [balance-books
          get-shape]
         [bank-balance-sheet] ;;third cycle, "bank balance sheet"
      ]
  ]
  tick
end
to do-business  ;;turtle procedure
  rt random-float 360
  fd 1

  if ((savings > 0) or (wallet > 0) or (bank-to-loan > 0))
    [set customer one-of other turtles-here
     if customer != nobody
     [if (random 2) = 0                      ;; 50% chance of trading with customer
           [ifelse (random 2) = 0            ;; 50% chance of trading $5 or $2
              [ask customer [set wallet wallet + 5] ;;give 5 to customer
               set wallet (wallet - 5) ] ;;take 5 from wallet
              [ask customer [set wallet wallet + 2] ;;give 2 to customer
               set wallet (wallet - 2) ] ;;take 2 from wallet
           ]
        ]
     ]
end
;; First checks balance of the turtle's wallet, and then either puts
;; a positive balance in savings, or tries to get a loan to cover
;; a negative balance.  If it cannot get a loan (if bank-to-loan < 0)
;; then it maintains the negative balance until the next round.  It
;; then checks if it has loans and money in savings, and if so, will
;; proceed to pay as much of that loan off as possible from the money
;; in savings
to balance-books
  ifelse (wallet < 0)
    [ifelse (savings >= (- wallet))
       [withdraw-from-savings (- wallet)]
       [if (savings > 0)
          [withdraw-from-savings savings]
        set temp-loan bank-to-loan           ;;temp-loan = amount available to borrow
        ifelse (temp-loan >= (- wallet))
          [take-out-loan (- wallet)]
          [take-out-loan temp-loan]
       ]
     ]
    [deposit-to-savings wallet]

  if (loans > 0 and savings > 0)            ;; when there is money in savings to payoff loan
    [ifelse (savings >= loans)
       [withdraw-from-savings loans
        repay-a-loan loans]
       [withdraw-from-savings savings
        repay-a-loan wallet]
    ]
end
;; Sets aside required amount from liabilities into
;; reserves, regardless of outstanding loans.  This may
;; result in a negative bank-to-loan amount, which
;; means that the bank will be unable to loan money
;; until it can set enough aside to account for reserves.
to bank-balance-sheet ;;update monitors
  set bank-deposits sum [savings] of turtles
  set bank-loans sum [loans] of turtles
  set bank-reserves (reserves / 100) * bank-deposits
  set bank-to-loan bank-deposits - (bank-reserves + bank-loans)
end
to deposit-to-savings [amount] ;;fundamental procedures
  set wallet wallet - amount
  set savings savings + amount
end
to withdraw-from-savings [amount] ;;fundamental procedures
  set wallet (wallet + amount)
  set savings (savings - amount)
end
to repay-a-loan [amount] ;;fundamental procedures
  set loans (loans - amount)
  set wallet (wallet - amount)
  set bank-to-loan (bank-to-loan + amount)
end


to take-out-loan [amount] ;;fundamental procedures
  set loans (loans + amount)
  set wallet (wallet + amount)
  set bank-to-loan (bank-to-loan - amount)
end
to-report savings-total
  report sum [savings] of turtles
end
to-report loans-total
  report sum [loans] of turtles
end
to-report wallets-total
  report sum [wallet] of turtles
end
to-report money-total
  report sum [wallet + savings] of turtles
end
; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license. 
