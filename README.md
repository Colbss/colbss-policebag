# colbss-policebag

# Setup

1. Add the following to `/resources/[qb]/qb-core/shared/items.lua`:

```
['policebag']                     = {['name'] = 'policebag',                ['label'] = 'Police Equipment Bag',   ['weight'] = 2000,         ['type'] = 'item',         ['image'] = 'police_bag.png',               ['unique'] = true,          ['useable'] = true,      ['shouldClose'] = true,      ['combinable'] = nil,   ['description'] = 'A bag of police equipment'},
```

2. Add `police_bag.png` into `[qb]/qb-inventory/html/images`
