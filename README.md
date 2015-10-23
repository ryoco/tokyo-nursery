# Tokyo non-authorized nursery map

## Usage

```
  bundle install --path vendor/bundle  
```

You need to make a csv file. (time consuming!)
Please download the [tokyo non-authorized nursery excel](http://www.fukushihoken.metro.tokyo.jp/kodomo/hoiku/ninkagai/babyichiran_koukai.html) file.

```
  bundle exec ruby_scripts/get_geo.rb csv_data/nursery_data.csv sonohoka.xls baby.xls 
```

You need to lunch redis.

```
  foreman start
```

then, access http://localhost:9292

## env file

Use `env.rb` file

## TODO

1. Fix UI
2. Fix date formats
3. Research google map API response ZERO_RESULTS

## License

MIT
