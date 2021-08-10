# Social aggregator test task

## Requirements
1) ruby >= 2.7

## Startup
`bundle exec rackup`

## Thoughs
1) We actually can retry if api call fails and it would be my number one improvement. Im just out of time :) it will be really easy with Task monad.
2) I would prefer explicit timeouts in ApiClient
3) In real world i guess we also need throlter
4) fast_json_serializer or similar would also be required
5) Maybe we can tune data structures so we can get rid of merges
