import QtQuick

QtObject {
    readonly property QtObject md3: QtObject {
        <* for name, color in colors *>
        readonly property color {{ name }}: "{{ color.default.hex }}"
        <* endfor *>
    }
}