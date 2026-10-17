#!/usr/bin/env python3
"""Subnet calculator for practising CIDR maths.

Examples:
    python3 subnet_calculator.py 10.0.0.0/20
    python3 subnet_calculator.py 10.0.0.0/16 --split 24
    python3 subnet_calculator.py 10.0.0.0/22 --contains 10.0.5.20
"""
import argparse
import ipaddress
import sys

AWS_RESERVED = 5  # AWS reserves 5 addresses in every subnet
MAX_LISTED = 16


def describe(network: ipaddress.IPv4Network) -> None:
    total = network.num_addresses
    hosts = list(network.hosts()) if total <= 65536 else None

    print(f"Network:            {network}")
    print(f"Netmask:            {network.netmask}")
    print(f"Wildcard mask:      {network.hostmask}")
    print(f"Range:              {network.network_address} - {network.broadcast_address}")
    print(f"Total addresses:    {total:,}")
    print(f"Usable (classic):   {max(total - 2, 0) if network.prefixlen < 31 else total:,}")
    print(f"Usable (AWS):       {max(total - AWS_RESERVED, 0):,}")
    if hosts:
        print(f"First/last host:    {hosts[0]} - {hosts[-1]}")
    print(f"Private range:      {'yes' if network.is_private else 'no'}")


def split(network: ipaddress.IPv4Network, new_prefix: int) -> None:
    if new_prefix < network.prefixlen or new_prefix > 32:
        sys.exit(f"--split must be between /{network.prefixlen} and /32")
    subnets = list(network.subnets(new_prefix=new_prefix))
    print(f"\n{network} split into /{new_prefix}: {len(subnets):,} subnets "
          f"of {subnets[0].num_addresses:,} addresses each")
    for subnet in subnets[:MAX_LISTED]:
        print(f"  {subnet}")
    if len(subnets) > MAX_LISTED:
        print(f"  ... and {len(subnets) - MAX_LISTED:,} more (last: {subnets[-1]})")


def main() -> None:
    parser = argparse.ArgumentParser(description="IPv4 subnet calculator")
    parser.add_argument("cidr", help="network in CIDR notation, e.g. 10.0.0.0/16")
    parser.add_argument("--split", type=int, metavar="PREFIX",
                        help="split the network into subnets of this prefix length")
    parser.add_argument("--contains", metavar="IP",
                        help="check whether an IP address is inside the network")
    args = parser.parse_args()

    try:
        # strict=False accepts host addresses like 10.0.1.77/24 and normalizes them.
        network = ipaddress.ip_network(args.cidr, strict=False)
    except ValueError as err:
        sys.exit(f"Invalid CIDR: {err}")
    if network.version != 4:
        sys.exit("Only IPv4 is supported in this exercise")

    describe(network)

    if args.split is not None:
        split(network, args.split)

    if args.contains:
        try:
            ip = ipaddress.ip_address(args.contains)
        except ValueError as err:
            sys.exit(f"Invalid IP: {err}")
        verdict = "IS" if ip in network else "is NOT"
        print(f"\n{ip} {verdict} inside {network}")


if __name__ == "__main__":
    main()
