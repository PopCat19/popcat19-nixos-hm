# alpine-apk-resolver.awk
#
# Purpose: Resolve transitive APK dependencies from APKINDEX
#
# Strip =version from provider keys and dep references before matching.
# Partial match: dep=libfoo matches prov key so:libfoo.so.X
{
  if (NF == 0) {
    if (p != "") {
      all[p] = ver
      orig[p] = (origX != "" ? origX : p)
      repo[p] = (repoX != "" ? repoX : "main")
      if (d != "") {
        n = split(d, dp, " ")
        for (i = 1; i <= n; i++) {
          x = dp[i]; sub(/=.*$/, "", x)
          if (x != "") deps[p] = deps[p] (deps[p] ? " " : "") x
        }
      }
      if (q != "") {
        n = split(q, pr, " ")
        for (i = 1; i <= n; i++) {
          key = pr[i]; sub(/=.*$/, "", key)
          if (key != "") prov[key] = p
        }
      }
    }
    p = ver = d = q = origX = repoX = ""
    next
  }
  k = substr($0, 1, index($0, ":") - 1)
  v = substr($0, index($0, ":") + 1)
  sub(/^ /, "", v)
  if (k == "P") p = v
  else if (k == "V") ver = v
  else if (k == "o") origX = v
  else if (k == "C") repoX = v
  else if (k == "D") d = v
  else if (k == "p") q = v
}

END {
  while ((getline line < seed) > 0) {
    gsub(/[[:space:]]+/, "", line)
    if (line != "") q2[line] = 1
  }
  close(seed)

  while (length(q2) > 0) {
    for (n in q2) {
      delete q2[n]
      if (n in res) continue
      if (!(n in all)) { unres[n] = 1; continue }
      res[n] = 1
      if (deps[n] != "") {
        m = split(deps[n], dp2, " ")
        for (i = 1; i <= m; i++) {
          dep = dp2[i]
          pvd = ""
          if (dep in prov) pvd = prov[dep]
          if (pvd == "" && (dep in all)) pvd = dep
          if (pvd == "") {
            pat = "^so:" dep "\\."
            for (pv in prov) if (pv ~ pat) { pvd = prov[pv]; break }
          }
          if (pvd != "" && !(pvd in res)) q2[pvd] = 1
        }
      }
    }
  }

  for (p in res) print p, all[p], orig[p], repo[p]
  for (u in unres) print "# UNRESOLVED:" u > "/dev/stderr"
}
