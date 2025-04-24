### Database size : 37 GB

#### Logical backup duration

| Format    | Options | Duration (s) | Dump Size |
|-----------|---------|--------------|-----------|
| plain     | -       | 161          | 23G       |
| tar       | -       | 239          | 23G       |
| Custom    | Default | 187          |           |
| Custom    | Z 0     | 167          | 24G       |
| Custom    | Z 5     | 184          | 651M      |
| Custom    | Z 9     | 257          | 632M      |
| Custom    | lz4:5   | 161          | 1200M     |
| Custom    | gzip:5  | 188          | 651M      |
| Directory | j 0     | 187          | 650       |
| Directory | j 2     | 125          | 650       |
| Directory | j 4     | 120          | 650       |



#### Physical backup duration


| Format             | Options (982MB) | Duration (s)    | Dump Size |
|--------------------|-----------------|-----------------|-----------|
| plain              | -               | 165             | 37.1G     |
| tar                | -               | 161             | 37.1G     |
| Zip                | 9               | 2816 (~ 48 min) | 1989 MB   |
| incr1              | -               | 212             | 1229 MB   |
| incr2              | -               | 207             | 1229 MB   |
| incr3              | -               | 211             | 1229 MB   |
| combine            | -               | 162             | -         |
| Restore            | -               | 0               | -         |
| Restore + recover  | -               | 17              | -         |
