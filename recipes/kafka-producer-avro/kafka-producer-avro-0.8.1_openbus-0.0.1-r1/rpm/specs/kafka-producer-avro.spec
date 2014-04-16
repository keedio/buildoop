# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Kafka Producer Avro tag -> release-0.8.1
%define kafka_producer_avro_base_version 0.8.1
%define kafka_producer_avro_release openbus0.0.1_1

%define lib_kafka_producer_avro /usr/lib/kafka/lib/kafka-producer-avro
%define etc_kafka /etc/kafka/conf
%define bin_kafka /usr/lib/kafka/bin

Name: kafka-producer-avro
Version: %{kafka_producer_avro_base_version}
Release: %{kafka_producer_avro_release}
Summary: Avro Producer for Kafka v0.8 
URL: https://github.com/buildoop/AvroRepoKafkaProducerTest
Vendor: The Redoop Team
Packager: Javi Roman <javiroman@redoop.org>
Group: Development/Libraries
Buildroot: %{_topdir}/INSTALL/%{name}-%{version}
BuildArch: noarch
License: APL2
Source0: AvroRepoKafkaProducerTest.git.tar.gz
Source1: rpm-build-stage
Source2: install_kafka-producer-avro.sh
Requires: kafka, avro-libs

%if  0%{?mgaversion}
Requires: bsh-utils
%else
Requires: sh-utils
%endif

%description 
This is a Kafka producer for testing purposes. The producer
send two simple avro files in order to check the connection
with the "Avro Server Schema Repository" used by Camus consummer.

%prep
%setup -n AvroRepoKafkaProducerTest.git

%build
sh %{SOURCE1}

%install
%__rm -rf $RPM_BUILD_ROOT
sh %{SOURCE2} \
          --build-dir=. \
          --prefix=$RPM_BUILD_ROOT

%files 
%defattr(644,root,root,755)
%dir %{lib_kafka_producer_avro}
%{lib_kafka_producer_avro}/*.jar
%{bin_kafka}/*.sh

%dir %{etc_kafka}
%config(noreplace) %{etc_kafka}/*

