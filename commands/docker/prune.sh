#!/bin/bash

d.prune() {
  docker system prune -a --volumes
}
