#include "extension.h"

VALUE mBubblezone;
VALUE cManager;
VALUE cZoneInfo;

static VALUE bubblezone_new_global_rb(VALUE self) {
  bubblezone_new_global();
  return Qnil;
}

static VALUE bubblezone_global_close_rb(VALUE self) {
  bubblezone_global_close();
  return Qnil;
}

static VALUE bubblezone_global_set_enabled_rb(VALUE self, VALUE enabled) {
  bubblezone_global_set_enabled(RTEST(enabled) ? 1 : 0);
  return enabled;
}

static VALUE bubblezone_global_enabled_rb(VALUE self) {
  return bubblezone_global_enabled() ? Qtrue : Qfalse;
}

static VALUE bubblezone_global_new_prefix_rb(VALUE self) {
  char *prefix = bubblezone_global_new_prefix();
  VALUE rb_prefix = rb_utf8_str_new_cstr(prefix);
  bubblezone_free(prefix);

  return rb_prefix;
}

static VALUE bubblezone_global_mark_rb(VALUE self, VALUE zone_id, VALUE text) {
  Check_Type(zone_id, T_STRING);
  Check_Type(text, T_STRING);

  char *result = bubblezone_global_mark(StringValueCStr(zone_id), StringValueCStr(text));
  VALUE rb_result = rb_utf8_str_new_cstr(result);
  bubblezone_free(result);

  return rb_result;
}

static VALUE bubblezone_global_clear_rb(VALUE self, VALUE zone_id) {
  Check_Type(zone_id, T_STRING);
  bubblezone_global_clear(StringValueCStr(zone_id));
  return Qnil;
}

static VALUE bubblezone_global_get_rb(VALUE self, VALUE zone_id) {
  Check_Type(zone_id, T_STRING);

  unsigned long long handle = bubblezone_global_get(StringValueCStr(zone_id));

  if (handle == 0) {
    return Qnil;
  }

  return zone_info_wrap(cZoneInfo, handle);
}

static VALUE bubblezone_global_scan_rb(VALUE self, VALUE text) {
  Check_Type(text, T_STRING);

  char *result = bubblezone_global_scan(StringValueCStr(text));
  VALUE rb_result = rb_utf8_str_new_cstr(result);
  bubblezone_free(result);

  return rb_result;
}

static VALUE bubblezone_upstream_version_rb(VALUE self) {
  char *version = bubblezone_upstream_version();
  VALUE rb_version = rb_utf8_str_new_cstr(version);
  bubblezone_free(version);

  return rb_version;
}

static VALUE bubblezone_version_rb(VALUE self) {
  VALUE gem_version = rb_const_get(self, rb_intern("VERSION"));
  VALUE upstream_version = bubblezone_upstream_version_rb(self);
  VALUE format_string = rb_utf8_str_new_cstr("bubblezone v%s (upstream %s) [Go native extension]");

  return rb_funcall(rb_mKernel, rb_intern("sprintf"), 3, format_string, gem_version, upstream_version);
}

__attribute__((__visibility__("default"))) void Init_bubblezone(void) {
  mBubblezone = rb_define_module("Bubblezone");

  Init_bubblezone_manager();
  Init_bubblezone_zone_info();

  rb_define_singleton_method(mBubblezone, "new_global", bubblezone_new_global_rb, 0);
  rb_define_singleton_method(mBubblezone, "close", bubblezone_global_close_rb, 0);
  rb_define_singleton_method(mBubblezone, "enabled=", bubblezone_global_set_enabled_rb, 1);
  rb_define_singleton_method(mBubblezone, "enabled?", bubblezone_global_enabled_rb, 0);
  rb_define_singleton_method(mBubblezone, "new_prefix", bubblezone_global_new_prefix_rb, 0);
  rb_define_singleton_method(mBubblezone, "mark", bubblezone_global_mark_rb, 2);
  rb_define_singleton_method(mBubblezone, "clear", bubblezone_global_clear_rb, 1);
  rb_define_singleton_method(mBubblezone, "get", bubblezone_global_get_rb, 1);
  rb_define_singleton_method(mBubblezone, "scan", bubblezone_global_scan_rb, 1);

  rb_define_singleton_method(mBubblezone, "upstream_version", bubblezone_upstream_version_rb, 0);
  rb_define_singleton_method(mBubblezone, "version", bubblezone_version_rb, 0);
}
