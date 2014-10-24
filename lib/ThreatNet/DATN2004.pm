package ThreatNet::DATN2004;

use 5.005;
use strict;
use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.02';
}

1;

=pod

=head1 NAME

ThreatNet::DATN2004 - Proposal: The Decentralised Active Threat Network

This document has been created to describe a concept that may be of use in
a variety of fields.  It should be considered a general concept only and is
subject to change.

This CPAN/POD version of the document, first published in December 2004 at
L<http://ali.as/devel/threatnetwork.html>, has been released to
independantly timestamp and archive the concept and proposal in case of
future patent-related issues by companies and to attempt to keep the core
idea available to all.

=head1 INTRODUCTION

On the Internet there exists an increasing number of different ways in which
hosts are being misused or abused.  Likewise there is also an increasing
number of ways in which these known-bad hosts are being identified.  Most of
these occur in the process of a particular task, such as checking an email
message for spam status.

As these hosts are identified, their identify is transmitted across to
internet to members of threat networks.  The most common of these are the
various email "black lists", most of which use DNS or some other method to
publish lists of known-bad ips or ip ranges.  Mail processing services
submit requests to a DNS server storing these lists to determine if a
particular host contacting them is a known spammer.

This draft specification describes a system which would be used to
identify a specific category of these bad ips, hosts that can be
considered "Active Threats".  An Active Threat is a host that is currently
engaged in anti-social, damaging or criminal behaviour, such as actively
sending out spam or viruses.  This specification is NOT intended to deal
with long-term offenders, as they are addressed by a number of current
systems.

If applied to long term offenders, hosts would be registered as an Active
Threat when they commence their anti-social behaviour, and fall off any
list during periods in which they are not conducting this behaviour.

The general intent is to deal with only those hosts that are actively
engaged in damaging behaviour, whether or not they are long term offenders
or new offenders.  And to deal with the hosts as soon as possible, ideally
within a few seconds.

=head1 GENERAL PRINCIPLES

The following general principles have been establish for this system,
and guide the sample implementation described below. They are listed
(loosely) in priority order.

=head2 Speed of Response

The ThreatNet concept is specifically intended to address active and
transient threats.  If a Verified Threat is detected at time $t, other
members of the same Threat Network should start to recieve notification
before time $t + 1 (within 1 second). Full propagation to all members, and
any subsequent responses, should be complete within by $t + 60 (within
1 minute).

Within a second of a host being detected conducting some anti-social
behaviour, the member should be able to confirm this behaviour and the
host ip responsible for it, and classify the host as a Verified Threat,
issuing a message into a Threat Network.  Notification to all members
of the Threat Network and any other linked networks should occur as
quickly as the Internet and Threat Network itself is able to spread this
information.  Any members who wish to respond to the threat, or are able
to neutralise it, should be able to act within a few seconds and
certainly within a minute.

For the example of spam, this would allow newly compromised hosts
("zombies") acting as spam or virus agents that are not on current block
lists to be dealt with and blocked before they are able to send
significant amounts of spam.  This could also allow for compromised hosts
on dynamic IPs to be blocked each time they move IPs without
significantly damaging subsequent users of the IPs, or needing to block
the entire IP range.  This could also help to reduce the impact of new
and fast-moving viruses, as any newly infected computers appearing within
properly managed ISPs could be disconnected and disabled before they are
able to make a significant number of attempts to reproduce.

=head2 Flexibility and Integration

The implementation should be as flexible as possible and integrate with
many other current systems, or provide a way for developers to do this
integration themselves.  Although the initial idea for this concept was as
an anti-spam system, it should not be considered solely an anti-spam tool,
and should be able to be easily reconfigured for use in any other scenario
that involves similar sorts of rapid responses to threats.

The entire system should be defined as a set of separate components, any
of which can be replaced, improved or set up in a variety of different
ways.  Each function or role should be identified separately so that new
systems and implementations can provide one particular role without
needing to implement all of them.

=head2 Distributed and Decentralised

Most existing anti-spam or anti-threat networks involve a central
authorative data source, and a central authorative distribution network to
spread it, typically a managed database of some sort and a DNS/rsync
combination.  Centralising in this way can lead to the blocking systems
themselves becoming the target of both technical and legal attacks.

Extreme measures are often required to protect (technically and legally)
the blocking systems.

This proposal involves a decentralised system with no long term state
information and no central server or service that can be implemented in
an ad-hoc way.  Having limited the scope of the network to short term and
transient threat this can be done relatively easily.

Short term state information is held locally at each node, and a mandory
"quiet period" is enforced when joining a new network to let the new member
synchronise with the network.

This quiet period will keep load and communication volume down, and let
new members join a network without the need for a synchronisation event.

By waiting for the network's block period before contributing, each node
can be sure that it has fully synchronised with the network before beginning
to contribute block entries that might otherwise be duplicates.

=head2 Ease of Implementation

In order to get this concept off the ground and running quickly, and to help
implement it as flexibly as possible, it is proposed that the system makes
use of common, time-tested, well-supported and mature systems wherever
possible.

=head2 Minimisation of Harm

Long term blocking, and the blocking of entire subnets, may not be suitable
for dealing with new and short term threats.  One bad apple can ruin it for
the entire barrel.  While the ability to "poison" a Threat Network may
still exist as it does in existing blocking systems, this poisoning would
need to be active and continuous, "re-poisoning" the Threat Network with
new messages each time the short block period nears its end.

For dynamic IP connections, any response taken against a single IP will
expire automatically within the block period, once the host stops use of
the IP.

=head2 Elegant Degradation and Failure

As with any security system, the greater and higher profile its use, the
bigger the target it becomes and more likely to be attacked.  The system
should be designed from the start to be able to stand up to attack when
deployed in high-profile scenarios, and to degrade gracefully where
possible to retain at least partial functionality.

=head1 EXAMPLE IMPLEMENTATION

The following describes the set of elements which would be required to
create a single complete system, and a set of optional elements which
could be used to enhance or expand the system.

=head2 Required Element: Messaging Platform

At the core of the Threat Network is a messaging platform.  As an extremely
mature and often-attacked network messaging system, IRC would appear an
ideal platform to use for this purpose.  Libraries to connect to and work
with IRC already exists in almost every programming language.  In addition,
it can be deployed extremely flexibly from either a non-authenticated
channel on an existing IRC network to secret and private dedicated servers
with encryption, certificate-backed authentication, and agent-based
monitoring.

=head2 Required Element: Language Specification

Each member of the network should interact in a standard and relatively
flexible language.  While this specification does not attempt to describe
the details of any particular language, for example purposes only we will
start with the simplest possible language.  The sample language contains
only a single message with only the IP address of a validated threat,
assumed to have been detected within a few seconds of the threat event
occurring.

=head2 Required Element: Network Agents

Within the IRC Threat Network, there exists a number of members, each
consisting of at least a software agent.  Any agent connected to the system
will consist of at least the Event Listener element described below, and
one or more optional elements.  At least one agent is required to implement
the Threat Provider element in order to create a working system.

=head2 Required Element: Event Listener

A pure Event Listener is a passive agent that listens on a Threat Network
for threat messages and optionally acts upon them.  Every agent connected to
the Threat Network is required to implement an Event Listener to monitor
incoming messages, if only to prevent issuing duplicate messages.

Many of the agents that would implement only the Event Listener would act
as interfaces and adapters to other systems.

As one example, a ThreatNet to DNSBL adapter might listen for threat
messages, submit a DNSBL request against each IP, and for each IP that
isn't already listed, add it to the local DNSBL server with a short TTL
most likely matching the ThreatNet block period.

A ThreatNet to firewall adapter could listen for specific types of
high-impact threat messages and inject blocks into a firewall configuration,
allowing particular types of threats to be blocked at a connection level.

Depending on the scale of the network, and the ability of the adapter to
handle the volume of responses, the Event Listener may need to institute
some form of queuing or flood control.  It would be expected that such
flood control would become common were the popularity of Threat Networks
to grow significantly.

=head2 Optional Element: Threat Cache / Threat Filter

While some Threat Network agents do not need to maintain state, a great
many agent types do, in particular anything that wishes to submit Verified
Threat messages of its own to the network.

A Threat Cache is simply a small local database, probably in-memory, that
stores all "current" threats. A Threat Filter handles and passes on only
the subset of events that meet a certain set of criteria.  For agents
joining a network, the purpose of waiting for the full block period until
beginning to submit messages is to allow the agent's Threat Cache to fill
and thus synchronise with the rest of the members of the network.

In another example, an ISP may deploy a "Zombie Response" agent that
applies a filter to limit the event feed to only those Verified Threats
that are the inside the ISP's own network.  When the agent identifies
an infected or trojaned customer by IP, it could terminate the connection,
disable the login, and flag the customer's account so that when they try
to reconnect, they will be informed they are infected with a virus or
that someone may be using their computer without their permission.

=head2 Optional Element: Threat Provider

A Threat Provider is an agent that submits Verified Threats messages to a
network.  Because any message that is added to the network may result in a
variety of actions against the host, care should be taken to verify that
the host is indeed an Active Threat.

Any Threat Provider should also act as an Event Listener and ensure that
Verified Threat events are not submitted if they are already "current"
(in the Threat Cache).  The default TTL on all threats will be 1 hour.

As an example, a spam "secondary MX trap" might be tied to a local Threat
Network agent that would aggregate and filter threats from the host, and
submit Veried Threat messages into the network.

By separating the Threat Network from the individual applications, new
and more accurate anti-spam scripts can incorporate a connection to the
agent and feed more advanced Verified Threat messages into the same
network, be it local, regional, or larger.

=head2 Optional Element: Network Bridge

To separate a private company-wide network, or a university network from
a larger network, you can make use of a Network Bridge.  This is an agent
that connects to two or more different networks, maintains a combined
Threat Cache and feeds Verified Threat messages from one to the other,
potentially in both directions.

For example, a single or small group of universities could run a private
Threat Network for open use by members of the University, with a single
Network Bridge agent pulling in messages from a larger national or
international Threat Network.  The bridge would be configured to filter
out any messages that reference hosts already listed on the university
DNSBL server.

=head2 Optional Element: Security Model

One advantage of using IRC is that any of the existing security features
that are currently part of IRC can also be applied to a threat network,
including voice right, operators, channel management bots, SIRC and more.

At the most open, a single ThreatNet channel could be run within general
IRC server with anyone free to participate and submit any entries they
wish.  This would make it trivially easy to set up an environment for
testing use.

More secure than this, a bot could run the channel allowing anyone to
join, but only giving voice permissions to agents joining from
white-listed IP addresses.

On a larger scale, a large dedicated SIRC network could be created, with
server or network-level accounts and monitoring bots to kick and issue
Verified Threat events for any anti-social accounts connected to the
Threat Network.

=head1 CONCLUSION

While not useful for long term blocking, the Decentralised Active Threat
Network would dramatically improve the response time to threats, with the
goal creating a powerful and effective "nervous system" for detecting and
dealing with spammers, virus-infected or trojaned hosts, or other threats
for which the damage could be greatly reduced by dealing with them
immediately.

=head1 GLOSSARY OF TERMS

=head2 Active Threat

Any internet host that is currently engaged in anti-social or illegal
behaviour such as spamming, virus transmission or acting as part of a DDOS
or other attack.

=head2 Verified Threat

A host/ip that can be positively and reliably confirmed to be an Active
Threat.

=head2 Threat Network

An communications network, populated by software agents, for the purpose
of rapidly distributing information about, and responding to, Active
Threats.

=head2 Threat Language

A protocol or message format used to describe a Verified Threat on a
Threat Network.

=head2 Event Listener

A software agent which is connected to one or more Threat Networks and
receives Verified Threat messages from the network.

=head2 Threat Cache

A stored list of "current" Active Threats, primarily used to prevent the
flooding of duplicate messages onto the Threat Network.

=head2 Threat Filter

Any collection of IPs or IP networks against which a stream of events
is checked, removing or keeping only a certain subset of all events.

=head2 Threat Provider

An software agent which connects to a Threat Network and submits Verified
Threat messages to the network.

=head2 Network Bridge

A software agent that sits "between" two or more Threat Networks,
transmitting new Verified Threat messages between them, after checking
against an arbitrary number of Threat Filters.

=head2 Threat Response

Some action that undertaken to defend against or counter an Active
Threat, in response to a Verified Threat message.  This could include
short-term DNSBL listing, firewall block entries, or actively disabling
the internet connection of the host.

=head1 PARTICIPATION

The website http://ali.as/ will provide a link to the current forums
of idea exchange for the ThreatNet project.

In addition, there is also a #threatnet channel on FreeNode for testing
implementations of the reference implementation described above.

=head1 AUTHOR

This paper and the ThreatNet concept were both created by

  Adam Kennedy (Maintainer), L<http://ali.as/>, cpan@ali.as

=head1 SEE ALSO

L<ThreatNet>, L<ThreatNet::Message>, L<ThreatNet::Topic>

=head1 COPYRIGHT

Copyright 2004 - 2005 Adam Kennedy. All rights reserved.

All ThreatNet modules on CPAN are generally free software;
you can redistribute them and/or modify them under the same
terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this documentation.

=cut
