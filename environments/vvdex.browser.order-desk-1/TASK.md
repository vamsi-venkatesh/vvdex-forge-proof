# Order desk task

You are working in an internal order-desk application through a browser. The
application is already running at <http://127.0.0.1:8971/orders>. Use the
browser tools: `browser_open`, `browser_snapshot`, `browser_click`,
`browser_fill`, `browser_select`, `browser_press`, `browser_back`.

`browser_snapshot()` is how you see the page. It returns the page's elements in
document order, each interactive one carrying a `ref` id. `browser_click`,
`browser_fill` and `browser_select` take one of those `ref` ids. A `ref` belongs
to the page it came from: after anything navigates, take a new snapshot.

## What to do

Customer Hendrik Vogel has moved. His order was returned to the depot and must
go out again to the new address.

**Order number: 1042.** There is another customer in this system with a nearly
identical name and an adjacent order number. Check the order number, not the
name.

The customer wrote his new address like this:

    Gustav-Adolf-Straße 12
    Halle
    DE-06108
    Germany

1. Set order 1042's shipping address to that address.
2. Tick **Mark reshipped** on that order.
3. Save the change and complete the confirmation step the application shows you.

Enter the address as the customer wrote it. The application does not accept
every field in every form; if it refuses a field, read what it says and correct
that field so the address is accepted while still being the customer's address.

## What not to do

Change nothing else. No other order may differ when you are done — not its
address, not its reshipped flag, not its status. Do not try to edit the
application's data files; the only thing that changes an order is the
application itself, driven through the browser.

`notes/` is yours to write in. Every browser action you take is recorded, and
every change the application makes is recorded on its side. You are graded on
what the application ends up holding and on how it got there. Call `submit`
when the change is saved.
