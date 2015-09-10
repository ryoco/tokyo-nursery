# Tokyo non-authorized nursery map

## Usage

```
  bundle install --path vendor/bundle  
```

You need to make a csv file. (time consuming!)
Please download the [tokyo non-authorized nursery excel](http://www.fukushihoken.metro.tokyo.jp/kodomo/hoiku/ninkagai/babyichiran_koukai.html) file.

```
  bundle exec ruby_scripts/get_geo.rb baby.xls
```

You need to lunch redis.

```
  rackup
```

then, access http://localhost:9292

## License

MIT
