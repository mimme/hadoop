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

load hadoop-functions_test_helper

@test "hadoop_add_classpath (simple not exist)" {
  run hadoop_add_classpath testvar
  [ "${status}" -eq 1 ]
}

@test "hadoop_add_classpath (simple wildcard not exist)" {
  run hadoop_add_classpath testvar/*
  [ "${status}" -eq 1 ]
}

@test "hadoop_add_classpath (simple exist)" {
  run hadoop_add_classpath "${TMP}"
  [ "${status}" -eq 0 ]
}

@test "hadoop_add_classpath (simple wildcard exist)" {
  run hadoop_add_classpath "${TMP}/*"
  [ "${status}" -eq 0 ]
}

@test "hadoop_add_classpath (simple dupecheck)" {
  hadoop_add_classpath "${TMP}/*"
  hadoop_add_classpath "${TMP}/*"
  echo ">${CLASSPATH}<"
  [ "${CLASSPATH}" = "${TMP}/*" ]
}

@test "hadoop_add_classpath (default order)" {
  hadoop_add_classpath "${TMP}/*"
  hadoop_add_classpath "/tmp"
  echo ">${CLASSPATH}<"
  [ "${CLASSPATH}" = "${TMP}/*:/tmp" ]
}

@test "hadoop_add_classpath (after order)" {
  hadoop_add_classpath "${TMP}/*"
  hadoop_add_classpath "/tmp" after
  echo ">${CLASSPATH}<"
  [ "${CLASSPATH}" = "${TMP}/*:/tmp" ]
}

@test "hadoop_add_classpath (before order)" {
  hadoop_add_classpath "${TMP}/*"
  hadoop_add_classpath "/tmp" before
  echo ">${CLASSPATH}<"
  [ "${CLASSPATH}" = "/tmp:${TMP}/*" ]
}

@test "hadoop_add_classpath (simple dupecheck 2)" {
  hadoop_add_classpath "${TMP}/*"
  hadoop_add_classpath "/tmp"
  hadoop_add_classpath "${TMP}/*"
  echo ">${CLASSPATH}<"
  [ "${CLASSPATH}" = "${TMP}/*:/tmp" ]
}

@test "hadoop_add_classpath (dupecheck 3)" {
  hadoop_add_classpath "${TMP}/*"
  hadoop_add_classpath "/tmp" before
  hadoop_add_classpath "${TMP}/*"
  hadoop_add_classpath "/tmp" after
  echo ">${CLASSPATH}<"
  [ "${CLASSPATH}" = "/tmp:${TMP}/*" ]
}

@test "hadoop_add_classpath (complex ordering)" {
  local j
  local style="after"

  # 1 -> 2:1 -> 2:1:3 -> 4:2:1:3 -> 4:2:1:3:5

  for j in {1..5}; do
    mkdir ${TMP}/${j}
    hadoop_add_classpath "${TMP}/${j}" "${style}"
    if [ "${style}" = "after" ]; then
      style=before
    else
      style=after
    fi
  done
  echo ">${CLASSPATH}<"
  [ "${CLASSPATH}" = "${TMP}/4:${TMP}/2:${TMP}/1:${TMP}/3:${TMP}/5" ]
}