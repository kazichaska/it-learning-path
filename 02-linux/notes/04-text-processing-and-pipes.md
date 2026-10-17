# 4 · Text Processing & Pipes

> **The Unix philosophy:** small tools that each do one thing well, connected with pipes. This is how you answer questions about logs in seconds.

## Standard streams

| Stream | Number | Default |
|---|---|---|
| stdin (input) | 0 | Keyboard |
| stdout (output) | 1 | Terminal |
| stderr (errors) | 2 | Terminal |

## Redirection

```bash
cmd > out.txt          # stdout to file (overwrite)
cmd >> out.txt         # stdout to file (append)
cmd 2> err.txt         # stderr to file
cmd > all.txt 2>&1     # stdout AND stderr to the same file
cmd 2>/dev/null        # throw errors away
cmd < input.txt        # read stdin from a file
cmd | tee out.txt      # show on screen AND save to file
```

## Pipes

`|` sends the stdout of one command into the stdin of the next:
```bash
cat access.log | grep " 500 " | wc -l       # how many 500 errors?
```

## The essential toolkit

### grep: search
```bash
grep "ERROR" app.log              # lines containing ERROR
grep -i "error" app.log           # case-insensitive
grep -v "DEBUG" app.log           # lines NOT containing DEBUG
grep -c "ERROR" app.log           # count matching lines
grep -n "ERROR" app.log           # show line numbers
grep -r "password" /etc/app/      # search recursively in a directory
grep -E "ERROR|WARN" app.log      # extended regex: either word
grep -A3 -B2 "Exception" app.log  # 3 lines After, 2 Before each match
```

### cut, sort, uniq, wc
```bash
cut -d: -f1 /etc/passwd           # field 1, split on ':' → usernames
sort file                         # alphabetical
sort -n file                      # numeric
sort -rn file                     # numeric, reversed
sort -k3 -n file                  # by column 3
uniq                              # remove *adjacent* duplicates (so sort first!)
uniq -c                           # count occurrences
wc -l                             # count lines
```

### awk: columns and simple logic
```bash
awk '{print $1}' access.log                   # 1st column
awk '{print $1, $9}' access.log               # columns 1 and 9
awk '$9 >= 500' access.log                    # lines where column 9 ≥ 500
awk -F, '{sum += $3} END {print sum}' data.csv  # sum column 3 of a CSV
```

### sed: find and replace (stream editor)
```bash
sed 's/foo/bar/' file              # replace first "foo" per line (prints result)
sed 's/foo/bar/g' file             # replace all
sed -i 's/8080/9090/g' config.ini  # edit in place (Linux)
sed -i '' 's/8080/9090/g' config.ini  # edit in place (macOS)
sed -n '10,20p' file               # print lines 10–20
```

### tr, xargs
```bash
echo "Hello" | tr 'a-z' 'A-Z'                 # → HELLO
find . -name "*.log" | xargs rm               # pass results as arguments
find . -name "*.log" -print0 | xargs -0 rm    # safe with spaces in names
```

## 🔥 Real-world one-liners (nginx/Apache access logs)

Log format: `IP - - [date] "METHOD /path HTTP/1.1" STATUS SIZE ...`

```bash
# Top 10 IP addresses by number of requests
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head

# Count of each HTTP status code
awk '{print $9}' access.log | sort | uniq -c | sort -rn

# Top 10 most requested paths
awk '{print $7}' access.log | sort | uniq -c | sort -rn | head

# All 5xx errors, live, as they happen
tail -f access.log | awk '$9 ~ /^5/'

# Which IPs caused 404s?
awk '$9 == 404 {print $1}' access.log | sort | uniq -c | sort -rn | head
```

Try them on the sample log: [`../../04-programming/python/sample-access.log`](../../04-programming/python/sample-access.log). The same analysis in Python: [`log_analyzer.py`](../../04-programming/python/log_analyzer.py).

## 🧠 Practice (use the sample log above)
1. How many requests are in the log?
2. How many requests returned a 5xx status?
3. Which IP made the most requests?

<details><summary>Answers</summary>

```bash
LOG=../../04-programming/python/sample-access.log
wc -l < "$LOG"
awk '$9 ~ /^5/' "$LOG" | wc -l
awk '{print $1}' "$LOG" | sort | uniq -c | sort -rn | head -1
```
</details>
