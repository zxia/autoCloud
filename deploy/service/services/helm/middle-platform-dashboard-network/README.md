# China Telecom sipservice Helm Chart

China Telecom - Confidential\
Do not use, distribute, or copy without consent of China Telecom.\
Copyright (c)  2021 China Telecom. All rights reserved.

## Description

This is the Helm chart used to deploy the China Telecom 5GMC SIP on Kubernetes.

## Prerequisites

* Kubernetes >= 1.18

## values.yaml

The following is a high-level description of the possible values in the
values.yaml file to aid in localization.

Parameter | Description | Default
--------- | ----------- | -------
| `image.oam.repository`            | sipservice OAM Image     |  ActivePilot:5000/centos8-5GMC SIP6-staging 
| `image.oam.tag`                   | sipservice Image Tag |  6.0.1
| `pods.oam.type`                   | the type "oam" can be renamed by the value, the value should follow up the dns name format  |   oam 
e pod terminationGracePeriodSeconds |  0