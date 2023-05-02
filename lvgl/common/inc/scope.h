#ifndef SCOPE_H
#define SCOPE_H

#include "lvgl.h"

#ifdef BUILD_STM32
  #include "chart.h"
  #include "menu.h"
#else
  #include "common/inc/chart.h"
  #include "common/inc/menu.h"
#endif

void scope_init(void);

#endif