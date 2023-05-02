#ifndef MENU_H
#define MENU_H

#include "lvgl.h"

#ifdef BUILD_STM32
    #include "chart.h"
#else
    #include "common/inc/chart.h"
    #include "lv_drv_conf.h"
#endif

#define MENU_WIDTH (LV_HOR_RES-SCOPE_CHART_WIDTH)
#define MENU_HEIGHT LV_VER_RES
#define MENU_X SCOPE_CHART_WIDTH

#define MENU_HOR_MARGIN 5
#define MENU_VER_MARGIN 5

#define MENU_ITEM_WIDTH MENU_WIDTH-3*MENU_HOR_MARGIN
#define MENU_ITEM_HEIGHT LV_VER_RES*1/5
#define MENU_INNER_WIDTH MENU_ITEM_WIDTH-2*MENU_HOR_MARGIN
#define MENU_INNER_HEIGHT MENU_ITEM_HEIGHT/2

#define MENU_ITEM_BKG 0x485D69
#define MENU_ITEM_BKG_SELECTED 0x32414A 
#define MENU_ITEM_LABEL 0xFCFCFC

#define MENU_INNER_BKG 0x282C34
#define MENU_INNER_BORDER 0x798AA8
#define MENU_INNER_BORDER_WIDTH 2

typedef void (*lv_callback)(lv_event_t*);

typedef enum {
    MODE_RUN,
    MODE_SINGLE,
    MODE_STOP
} SCOPE_MODE;

void change_mode(SCOPE_MODE target_mode);
void create_menu_item(lv_obj_t *parent, const char *text, lv_callback callback);
static void mode_callback(lv_event_t *event);
static void trigger_callback(lv_event_t *event);
static void scale_callback(lv_event_t *event);
void create_menu(void);

#endif