import 'package:hobbybuddy/widgets/app_bar.dart';
import 'package:hobbybuddy/widgets/responsive_wrapper.dart';
import 'package:flutter/material.dart';

class TabbarSwitcher extends StatefulWidget {
  final String appBarTitle;
  final List<Widget> upRightActions;
  final List<String> labels;
  final double stickyHeight;
  final List<Widget> tabbars;
  final Widget? listSticky;
  final bool? alwaysShowTitle;

  const TabbarSwitcher({
    super.key,
    required this.labels,
    required this.stickyHeight,
    required this.appBarTitle,
    required this.upRightActions,
    required this.tabbars,
    this.listSticky,
    this.alwaysShowTitle,
  });

  @override
  State<TabbarSwitcher> createState() => _TabbarSwitcher();
}

class _TabbarSwitcher extends State<TabbarSwitcher>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _isShrink = false;

  /*
  bool get _isShrink {
    return _scrollController.hasClients &&
        _scrollController.offset > widget.stickyHeight - 50;

  }

    */
  @override
  void initState() {
    _tabController = TabController(length: widget.labels.length, vsync: this);
    _scrollController.addListener(() {
      setState(() {
        _isShrink = _scrollController.hasClients &&
            _scrollController.offset > widget.stickyHeight - 50;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // https://stackoverflow.com/questions/71470499/custom-sliver-app-bar-in-flutter-with-an-image-and-2-text-widgets-going-into-app
    return Scaffold(
      appBar: MyAppBar(
        // toolbarHeight: 50,
        title: (widget.alwaysShowTitle != null && widget.alwaysShowTitle!) ||
                (_isShrink || widget.stickyHeight == 0)
            ? widget.appBarTitle
            : "",
        upRightActions: widget.upRightActions,
        shape: (widget.alwaysShowTitle != null && widget.alwaysShowTitle!) ||
                (_isShrink || widget.stickyHeight == 0)
            ? const Border()
            : Border(
                bottom: BorderSide(
                  width: 1,
                  color: Theme.of(context).dividerColor,
                ),
              ),
      ),
      body: SafeArea(
        child: ResponsiveWrapper(
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // https://github.com/flutter/flutter/issues/37152
                // to remove some space below tabbar
                SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverPadding(
                    // space between sticky elements and app bar
                    padding: const EdgeInsets.only(top: 0),
                    sliver: SliverAppBar(
                      scrolledUnderElevation: 0,
                      elevation: 1,
                      pinned: true,
                      expandedHeight: widget.stickyHeight,
                      automaticallyImplyLeading: false,
                      centerTitle: true,
                      backgroundColor: _isShrink || widget.stickyHeight == 0
                          ? Theme.of(context).appBarTheme.backgroundColor
                          : Theme.of(context).scaffoldBackgroundColor,
                      bottom: PreferredSize(
                        // height between app bar and tabbar
                        preferredSize: const Size.fromHeight(0),
                        child: TabBar(
                          tabs: widget.labels.map((e) => Tab(text: e)).toList(),
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                        ),
                      ),
                      flexibleSpace:
                          widget.stickyHeight != 0 && widget.listSticky != null
                              ? FlexibleSpaceBar(
                                  collapseMode: CollapseMode.pin,
                                  background: widget.listSticky,
                                )
                              : null,
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                Expanded(
                  child: TabBarView(
                    // for best performance, add to the stateful widgets
                    // with AutomaticKeepAliveClientMixin
                    controller: _tabController,
                    children: widget.tabbars,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
