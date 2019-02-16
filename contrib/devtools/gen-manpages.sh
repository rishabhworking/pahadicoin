#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

PAHADICOIND=${PAHADICOIND:-$SRCDIR/pahadicoind}
PAHADICOINCLI=${PAHADICOINCLI:-$SRCDIR/pahadicoin-cli}
PAHADICOINTX=${PAHADICOINTX:-$SRCDIR/pahadicoin-tx}
PAHADICOINQT=${PAHADICOINQT:-$SRCDIR/qt/pahadicoin-qt}

[ ! -x $PAHADICOIND ] && echo "$PAHADICOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
PHCVER=($($PAHADICOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$PAHADICOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $PAHADICOIND $PAHADICOINCLI $PAHADICOINTX $PAHADICOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${PHCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${PHCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m