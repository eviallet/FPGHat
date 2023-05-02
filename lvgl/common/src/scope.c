#ifdef BUILD_STM32
  #include "scope.h"
#else
  #include "common/inc/scope.h"
#endif

void scope_init(void) {
  create_scope_chart();
  create_menu();
}