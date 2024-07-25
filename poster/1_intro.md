# Introduction

The superconducting radio frequency (SRF) cavities that line the linear particle accelerator at Jefferson Lab allow for near zero energy loss and enable particles to travel at close to the speed of light. However, the highly specialized nature of SRF technology means Jefferson Lab must design, construct and test SRF cavities in house. Though this allows the Lab to produce cavities for accelerator facilities around the world, it also presents an exceedingly difficult challenge in inventory and data management. Pansophy, an internal data management system is an all-encompassing solution to this problem.

Pansophy is an internal website that is only accessible inside of Jefferson Lab's firewall. Its front end is written in ColdFusion, JavaScript and CSS, with ColdFusion being used mainly due to its ability to seamlessly embed SQL (Structured Query Language) onto a webpage. ColdFusion is an HTML-like language with its own plethora of custom tags and a built-in scripting language, CFScript.

SQL is used to query the two main relation Oracle databases: the PRIMeS (Production and Research Inventory Management System) and Travelers. Each database houses a collection of tables each with a primary key and various foreign keys. By cross referencing the correct tables, relevant information about a part or traveler can be discerned even when provided limited information.

To ensure the correctness and proper usability of Pansophy, typos and human error must be minimized. Thus, any automation of data collection that results in less manual entry by an engineer is very beneficial.
