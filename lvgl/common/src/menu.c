#ifdef BUILD_STM32
  #include "menu.h"
#else
  #include "common/inc/menu.h"
#endif


static SCOPE_MODE current_mode = MODE_RUN;

static const char *mode_run_text = " Run";
#define MODE_RUN_COLOR 0x33CC00
static const char *mode_single_text = " Single";
#define MODE_SINGLE_COLOR 0xFFCC33
static const char *mode_stop_text = " Stop";
#define MODE_STOP_COLOR 0xFF0000

static uint8_t item_index = 0;
static lv_obj_t *mode_icon;
static lv_obj_t *mode_label;

void change_mode(SCOPE_MODE target_mode) {
    current_mode = target_mode;
    if(target_mode == MODE_RUN) {
        lv_label_set_text(mode_icon, LV_SYMBOL_PLAY);
        lv_obj_set_style_text_color(mode_icon, lv_color_hex(MODE_RUN_COLOR), LV_STATE_DEFAULT);
        lv_label_set_text(mode_label, mode_run_text);
    } else if(target_mode == MODE_SINGLE) {
        lv_label_set_text(mode_icon, LV_SYMBOL_NEXT);
        lv_obj_set_style_text_color(mode_icon, lv_color_hex(MODE_SINGLE_COLOR), LV_STATE_DEFAULT);
        lv_label_set_text(mode_label, mode_single_text);
    } else {
        lv_label_set_text(mode_icon, LV_SYMBOL_STOP);
        lv_obj_set_style_text_color(mode_icon, lv_color_hex(MODE_STOP_COLOR), LV_STATE_DEFAULT);
        lv_label_set_text(mode_label, mode_stop_text);
    }
}

void create_menu_item(lv_obj_t* parent, const char* text, lv_callback callback) {
    // Menu item box
    lv_obj_t* item_box = lv_obj_create(parent);
    // Size and layout
    lv_obj_set_size(item_box, MENU_ITEM_WIDTH, MENU_ITEM_HEIGHT);
    lv_obj_set_flex_align(item_box, LV_FLEX_FLOW_COLUMN, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);
    lv_obj_set_flex_flow(item_box, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_style_pad_ver(item_box, MENU_VER_MARGIN, LV_STATE_DEFAULT);
    lv_obj_set_style_pad_hor(item_box, MENU_HOR_MARGIN, LV_STATE_DEFAULT);
    // Styling
    lv_obj_set_scrollbar_mode(item_box, LV_SCROLLBAR_MODE_OFF);
    lv_obj_set_style_bg_color(item_box, lv_color_hex(MENU_ITEM_BKG), LV_STATE_DEFAULT);
    lv_obj_set_style_bg_color(item_box, lv_color_hex(MENU_ITEM_BKG_SELECTED), LV_STATE_PRESSED);
    // Shadow
    // lv_obj_set_style_shadow_color(item_box, lv_color_hex(0x000000), LV_STATE_DEFAULT);
    // lv_obj_set_style_shadow_spread(item_box, 2, LV_STATE_DEFAULT);
    // lv_obj_set_style_shadow_width(item_box, 2, LV_STATE_DEFAULT);
    // lv_obj_set_style_shadow_opa(item_box, LV_OPA_10, LV_STATE_DEFAULT);
    // lv_obj_set_style_shadow_ofs_y(item_box, 2, LV_STATE_DEFAULT);

    // Menu item label
    lv_obj_t* label = lv_label_create(item_box);
    // Size and layout
    lv_obj_set_flex_align(label, LV_FLEX_FLOW_COLUMN, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);
    // Contents
    lv_label_set_text(label, text);
    // Styling
    lv_obj_set_style_text_font(label, &lv_font_montserrat_26, LV_STATE_DEFAULT);
    lv_obj_set_style_text_color(label, lv_color_hex(MENU_ITEM_LABEL), LV_STATE_DEFAULT);
    // Interactions
    lv_obj_clear_flag(label, LV_OBJ_FLAG_CLICKABLE);

    // Inner box
    lv_obj_t* inner_box = lv_obj_create(item_box);
    // Size and layout
    lv_obj_set_size(inner_box, MENU_INNER_WIDTH, MENU_INNER_HEIGHT);
    lv_obj_set_style_pad_all(inner_box, 12, LV_STATE_DEFAULT);
    lv_obj_set_flex_flow(inner_box, LV_FLEX_FLOW_ROW);
    // Styling
    lv_obj_set_scrollbar_mode(inner_box, LV_SCROLLBAR_MODE_OFF);
    lv_obj_set_style_bg_color(inner_box, lv_color_hex(MENU_INNER_BKG), LV_STATE_DEFAULT);
    lv_obj_set_style_border_color(inner_box, lv_color_hex(MENU_INNER_BORDER), LV_STATE_DEFAULT);
    lv_obj_set_style_border_width(inner_box, MENU_INNER_BORDER_WIDTH, LV_STATE_DEFAULT);
    // Interactions
    lv_obj_clear_flag(inner_box, LV_OBJ_FLAG_CLICKABLE);

    // Item callback
    lv_obj_add_event_cb(item_box, *callback, LV_EVENT_CLICKED, NULL);

    if(item_index == 0) { // Mode item
        mode_icon = lv_label_create(inner_box);
        lv_obj_set_style_text_font(mode_icon, &lv_font_montserrat_20, LV_STATE_DEFAULT);
        lv_obj_set_flex_align(mode_icon, LV_FLEX_ALIGN_START, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);
        mode_label = lv_label_create(inner_box);
        lv_obj_set_style_text_font(mode_label, &lv_font_montserrat_20, LV_STATE_DEFAULT);
        lv_obj_set_flex_align(mode_label, LV_FLEX_ALIGN_END, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_SPACE_EVENLY);

        change_mode(MODE_RUN);
    }
    item_index++;
}

static void mode_callback(lv_event_t* event) {
    switch(current_mode) {
        case MODE_RUN:
            change_mode(MODE_SINGLE);
            return;
        case MODE_SINGLE:
            change_mode(MODE_STOP);
            return;
        case MODE_STOP:
            change_mode(MODE_RUN);
            return;
        }
    
}

static int16_t cur_x = 0;
static void trigger_callback(lv_event_t *event) {
    cur_x++;
    add_data(CHART_CH1, cur_x, lv_rand(0, 100));
}

static void scale_callback(lv_event_t* event) {
}

void create_menu(void) {
    // Scrollable panel
    lv_obj_t * panel = lv_obj_create(lv_scr_act());
    // Size and layout
    lv_obj_set_size(panel, MENU_WIDTH, MENU_HEIGHT);
    lv_obj_set_pos(panel, MENU_X, 0);
    lv_obj_set_style_pad_all(panel, MENU_HOR_MARGIN, LV_STATE_DEFAULT);
    lv_obj_set_style_bg_color(panel, lv_color_hex(0x282C34), LV_STATE_DEFAULT);
    // Contents
    lv_obj_set_flex_flow(panel, LV_FLEX_FLOW_COLUMN);
    // Shadow
    lv_obj_set_style_shadow_color(panel, lv_color_hex(0x000000), LV_STATE_DEFAULT);
    lv_obj_set_style_shadow_spread(panel, 5, LV_STATE_DEFAULT);
    lv_obj_set_style_shadow_opa(panel, LV_OPA_10, LV_STATE_DEFAULT);
    lv_obj_set_style_shadow_width(panel, 2, LV_STATE_DEFAULT);

    // Fill menu
    create_menu_item(panel, "Mode", mode_callback);
    create_menu_item(panel, "Trigger", trigger_callback);
    create_menu_item(panel, "Scale", scale_callback);

}