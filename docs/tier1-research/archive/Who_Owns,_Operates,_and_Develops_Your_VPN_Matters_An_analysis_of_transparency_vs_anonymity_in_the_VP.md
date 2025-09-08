# Who Owns, Operates, and Develops Your VPN Matters: An analysis of transparency vs. anonymity in the VPN ecosystem, and implications for users | OTF

*New research from ICFP Fellow Benjamin Mixon-Baca finds that eight providers of popular, commercial VPN applications appear to hide the ownership and operations of their services, and contain serious privacy and security issues that put more than 700 million users at risk of authoritarian surveillance. Three of these providers are linked to the PLA and there is evidence that a Chinese national owns all eight.*

**Key Findings:**

-   Commercial VPNs serving over 700 million users with poor transparency standards permit attackers to remove encryption, a glaring security and privacy vulnerability.

-   A first group of VPNs has established links to China’s People’s Liberation Army (PLA) and a second group—with similarly deceptive practices—was newly discovered.

## Why VPN Transparency Matters

Virtual Private Networks (VPNs) are critical security and privacy infrastructure used by people globally to circumvent repressive censorship and surveillance, and protect their privacy and connections on public WiFi. They have grown significantly in popularity as more authoritarian governments censor the free and open internet. 

Commercial VPN providers operate with varying degrees of transparency and users must determine whether they value transparency more than anonymity when choosing a provider, as there are trade-offs with each.

**Transparency vs. Anonymity in the VPN Ecosystem**

VPNs are not designed for truly anonymous communications. When selecting a VPN provider, users are implicitly transferring trust from their internet service provider to the VPN provider. This transfer—despite often being overlooked or ignored—carries with it significant security implications, given the access the provider has to the user’s data. 

The benefit of a transparently operating VPN provider is that users know who can view their communications. The limitation of such a provider is that it can be identified easily by authorities and subpoenaed or targeted by cyber criminals, which could put users at risk. 

A VPN provider that operates anonymously (so less transparently) cannot be easily targeted by censors or cyber criminals, or subpoenaed by authorities—providing a level of protection to users. The downside is users do not know who can view their communications, which could increase their risk of surveillance or exploitation.

Information about a provider’s operations, ownership, and development is key for users to make informed decisions, but these details are often hard to find. In addition, some VPN providers—particularly the free services that monetize user data and serve ads—use ethically questionable practices when developing, marketing, and operating their VPNs. They take advantage of legal loopholes and attempt to hide who controls their services. For example, there are VPNs who cite Singapore (a country with strong privacy laws) as their country of origin on app stories—yet they are actually linked to China (a country with highly invasive privacy laws).

When VPN provider information such as this is not easy to find or the provider actively tries to hide this information, users risk entrusting their data to a provider that they might not have chosen otherwise. In contexts where individuals are prosecuted for expressing themselves online or accessing information that authorities blacklist, these types of VPNs put their users at great risk.   

## Project Overview

In an effort to bring greater visibility into the VPN ecosystem, [Information Controls Fellowship Program](https://www.opentech.fund/fellowships/icfp/) (ICFP) fellow [Benjamin Mixon-Baca](https://www.opentech.fund/fellows/ben-mixon-baca/), collaborated with Dr. Jeffrey Knockel of Bowdoin College and Dr. Jedidiah R. Crandell of Arizona State University to uncover who owns, operates, and develops 32 popular VPNs on the Google Play Store (with more than one billion downloads, collectively). These VPN apps are distributed by 21 seemingly distinct VPN providers and serve users in India, Indonesia, Russia, Pakistan, Saudi Arabia, Turkey, UAE, Bangladesh, Egypt, Algeria, Singapore, and Brazil.

They assigned the providers a multi-factor “transparency versus anonymity” score, with the goals of:

1.  helping users make more informed decisions when selecting a VPN provider; and
2.  encouraging app stores to clearly identify apps that operate transparently and those that do not.

Mixon-Baca and his fellow researchers also examined if there is a link between less transparency and security vulnerabilities.

## Significant Findings

**1\. Two clusters of VPN providers—whose apps have more than 700 million downloads, collectively—have egregious transparency offenses.**

Two groups of providers do not disclose that they are related or operate together, and appear to hide the ownership and operations of their services.

Previous research found that the first cluster—INNOVATING CONNECTING LIMITED, AUTUMN BREEZE PTE. LIMITED, and LEMON CLOVE PTE. LIMITED— are operated by the same Chinese national \[1\] and have links to the Chinese cybersecurity firm Qihoo 360 and the PLA \[2\] by examining their privacy policies and copyright filings. Mixon-Baca’s research dug deeper by manually analyzing their most popular VPN apps, and found that they also share code and infrastructure—even stronger indications of connection.

The second cluster of concerning VPN providers, which previous research has not investigated, includes MATRIX MOBILE PTE. LTD., ForeRaya Technologies PTE LTD, Wildlook Tech Pte Ltd., Hong Kong Silence Technology, and Yolo Technology Limited. While connections to Qihoo 360 could not be identified for these entities, their operational characteristics are similar to the first cluster (which does have ties to the Chinese cybersecurity firm). For example, their privacy policies reference Innovative Connecting. In addition, their apps share infrastructure and code.

**2\. Both clusters have a number of security vulnerabilities.**

The vulnerabilities include:

-   The use of Shadowsocks for tunneling: Shadowsocks (an open source proxy project designed to bypass internet censorship and geo-restrictions) was designed for *access* to the open internet only, and not for confidentiality—this is problematic as these apps are advertised as providing user security. 

-   Hard-coded passwords in their configuration that are shared across all users: The password is embedded within the source code, instead of stored securely elsewhere and retrieved at runtime. The fact that the password credentials are in the app code itself, makes them easily accessible to anyone who can view the code. An attacker who knows the password can decrypt the VPN’s encryption for all users, exposing the content they are accessing. This significantly compromises user security and privacy.

-   Susceptibility to blind-in/on-path client/server-side attacks (client side confirmed, server side implied): An attacker can intercept and even modify communication without the knowledge of the user, a serious violation of their privacy and security. 

-   Extraction of user location information, despite claiming that this is not collected.

These software issues are alarming, especially for the providers with links to the Chinese cybersecurity firm Qihoo 360. It calls into question the providers’ intentions when they are connected to the biggest cybersecurity firm in China, yet offer security-critical applications with glaring vulnerabilities.

**3\. Free commercial VPN apps are riskier than paid ones.**

While not all free commercial VPN apps operate in poor faith, using products such as TurboVPN, VPN Proxy Master and Snap VPN (supplied by the first cluster of providers), presents far more risk to user security and privacy than using a paid VPN app. This is because free commercial VPNs tend to capitalize on their users’ data, potentially using ethically questionable practices in their development, marketing, and operations.

![Test Image 1 1025x1009](https://www.opentech.fund/wp-content/uploads/2025/09/Test-Image-1-1025x1009.png)

#### [Read the full report](https://www.opentech.fund/wp-content/uploads/2025/08/VPN-Transparency-Report.pdf)

#### Access the [in-depth technical report](https://www.opentech.fund/wp-content/uploads/2025/09/Linking-Suspicious-and-Insecure-Apps-in-the-VPN-Ecosystem.pdf) of the research

---

**References**

\[[1](https://vpnpro.com/blog/hidden-vpn-owners-unveiled-97-vpns-23-companies/)\] “Who owns your VPN? 105 VPNs run by just 24 companies”, VPNPro, Dovyadas Vesa and Juste Kairyte-, October 2, 2024, [https://vpnpro.com/blog/hidden-vpn-owners-unveiled-97-vpns-23-companies/](https://vpnpro.com/blog/hidden-vpn-owners-unveiled-97-vpns-23-companies/) 

\[[2](https://www.techtransparencyproject.org/articles/apple-offers-apps-with-ties-to-chinese-military)\] “Apple Offers Apps with Ties to Chinese Military”, Tech Transparency Project, April 1, 2025,  [https://www.techtransparencyproject.org/articles/apple-offers-apps-with-ties-to-chinese-military](https://www.techtransparencyproject.org/articles/apple-offers-apps-with-ties-to-chinese-military)

---

*Open Technology Fund (OTF)’s* [*Information Controls Fellowship Program*](https://www.opentech.fund/fellowships/icfp/) *supports examination into how governments in countries, regions, or areas of OTF’s core focus are restricting the free flow of information, impeding access to the open internet, and implementing censorship mechanisms, thereby threatening the ability of global citizens to exercise basic human rights and democracy. The program supports fellows to work within host organizations that are established centers of expertise by offering competitively paid fellowships for three, six, nine, or twelve months in duration.*

---
Source: [Who Owns, Operates, and Develops Your VPN Matters: An analysis of transparency vs. anonymity in the VPN ecosystem, and implications for users | OTF](https://www.opentech.fund/news/who-owns-operates-and-develops-your-vpn-matters-an-analysis-of-transparency-vs-anonymity-in-the-vpn-ecosystem-and-implications-for-users/)